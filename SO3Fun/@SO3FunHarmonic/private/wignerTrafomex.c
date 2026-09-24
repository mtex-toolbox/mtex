/*=========================================================================
 * wignerTrafomex.c - eval of SO3FunHarmonic
 * 
 * The inputs are the fourier coefficients (fhat) of the harmonic 
 * representation of a SO(3) function SO3F and the bandwidth (N).
 * This harmonic representation will be transformed to a FFT(3) in terms
 * of Euler angles.
 * We calculate as output the corresponding fourier coefficient matrix up to
 * a multiplicative constant i^(k-l). That means:
 * The wignerTrafomex function just computes
 * $$\hat{h}_{k,j,l} = \sum_{n = \max \{|k|,|j|,|l|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k,l} \, d_n^{j,k}(0) \, d_n^{j,l}(0)$$
 * from the harmonic coefficients $\hat{f}_n^{k,l}$.
 * But the Wigner transform which computes the Fourier coefficients $\hat{g}_{k,j,l}$ reads as
 * $$\hat{g}_{k,j,l} = i^{k-l} \, \sum_{n = \max \{|k|,|j|,|l|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k,l} \, d_n^{j,k}(0) \, d_n^{j,l}(0).$$
 *
 * Therefore we use symmetry properties of SO3F to calculate only a part of
 * symmetrical SO(3) Fourier coefficients and to speed up the algorithm. 
 * The following symmetry properties are implemented:
 * 1) For the calculation of ghat we need Wigner-d matrices with Euler angle
 * beta = pi/2. There are a lot of symmetry properties in this Wigner-d
 * matrices. We use this to compute the Wigner-d's faster.
 * From the symmetry properties of the Wigner-d functions we get
 *                ghat(l,j,k) = (-1)^(k+l) ghat(l,-j,k).
 * 2) If SO3F is a real valued function, the SO(3) Fourier coefficients 
 * satisfy the symmetry property
 *                     fhat(n,k,l) = conj(fhat(n,-k,-l))
 * where conj denotes the conjugate complex. Hence we get
 *            ghat(k,j,l) = (-1)^(k+l) * conj(ghat(-k,j,-l)).
 * Moreover we can half the following FFT(3) to (-N:N)x(-N:N)x(0:N). 
 * Therefore ghat(:,:,0) has to be halved.
 * 3) If SO3F is an antipodal function, the SO(3) Fourier coefficients 
 * satisfy the symmetry property
 *                   fhat(n,k,l) = fhat(n,-l,-k).
 * Hence we have
 *              ghat(k,j,l) = (-1)^(k+l) * ghat(-l,j,-k).
 * 4) Similarly an r-fold symmetry axis along the Z-axis in right or left 
 * symmetry implies that the SO(3) Fourier coefficients satisfy
 *              fhat(n,k,l) = 0   if k mod r is not 0
 * or
 *              fhat(n,k,l) = 0   if l mod r is not 0.
 * Hence we get
 *              ghat(k,j,l) = 0   if k mod r is not 0
 * and
 *              ghat(k,j,l) = 0   if l mod r is not 0.
 * 5) Moreover an 2-fold symmetry along Y-axis yields 
 *            fhat(n,k,l) = (-1)^n fhat(n,-k,l)
 * for right symmetry and
 *            fhat(n,k,l) = (-1)^n fhat(n,k,-l)
 * in case of left symmetry.
 * Hence we have
 *            ghat(k,j,l) = (-1)^(k+j) * ghat(-k,j,l)
 * and
 *            ghat(k,j,l) = (-1)^(l+j) * ghat(k,j,-l).
 *
 * It is also possible to calculate ghat with even size in any dimension by
 * using the flag 2^1. Therefore zeros are added in front of the output 
 * 3-tensor. That is necessary since the nfft is done for indices -N-1 : N 
 * but the values are given for indices -N:N.
 *
 *
 * Syntax
 *   flags = 2^0+2^2+2^4;
 *   sym_axis = [1,2,2,1];
 *   ghat = wignerTrafomex(N,fhat,flags,sym_axis);
 * 
 * Input
 *  N        - bandwidth
 *  fhat     - SO(3) Fourier coefficient vector
 *  flags    - double where:
 *             2^0 -> use L_2-normalized Wigner-D functions
 *             2^1 -> make size of result even
 *             2^2 -> fhat are the fourier coefficients of a real valued function
 *             2^3 -> antipodal            (not implemented yet)
 *             2^4 -> use right and left symmetry
 *  sym_axis - vector [SRight-Y,SRight-Z,SLeft-Y,SLeft-Z] where SRight-Y,SLeft-Y are in {1,2} and 
 *             SRight-Z,SLeft-Z are in {1,2,3,4,6} and describes the countability of the symmetry axis
 *
 * Output
 *  ghat - up to a constant not (w.r.t. symmetries) reconstructed Wigner transformed SO(3) Fourier coefficients
 *
 *
 * This is a MEX-file for MATLAB.
 * 
 *=======================================================================*/

#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <stdio.h>    // For printf
#include <complex.h>
#include <string.h>
#ifdef _OPENMP // For parallelisation
#include <omp.h>
#endif
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include "wigner_d_quadrant_at_pi_half.c"   // three term recurrence relation for the Wigner-d matrices at pi/2
#include "L2_normalized_WignerD_functions.c"  // use L_2-normalized Wigner-D functions by scaling the fourier coefficients



// loop bounds of the orders k (right, rZ-fold) or l (left) of degree n, halve
// drops the negative ones; degrees 0 and 1 ignore the symmetries and are only
// halved by halve1
static void order_bounds(int n, int rZ, int halve, int halve1, int *min, int *max, int *step)
{
  if (n <= 1) { *min = halve1 ? 0 : -n; *max = n; *step = 1; return; }
  *min = -n + n % rZ;
  *max = n - n % rZ;
  *step = rZ;
  if (halve) *min = 0;
}

// Where ghat(k,j,l) is stored: at base[(k-k0)/rk + (j+j0)*sj + (l-l0)/rl*sl]
// for the multiples k-k0 of rk and l-l0 of rl
typedef struct { int k0, rk, j0, l0, rl; size_t sj, sl; } lattice;

// The computational routine
//   ghat(k,j,l) = sum_n fhat(n,k,l) d^n(k,-j) d^n(l,-j)
// for j >= 0 with the quadrant S(a,b) = d^n(-a,-b), from which
//   d^n(k,-j) = S(-k,j) for k <= 0,  (-1)^(n+k+j) S(k,j) for k > 0.
// The Wigner-d matrices of a block of degrees are computed first and then
// every row ghat(:,j,l) takes the whole block, which keeps it in cache.
static void calculate_ghat( const mxDouble bandwidth, mxComplexDouble *fhat,
                            const int isReal, const int isAntipodal, mxDouble *sym_axis,
                            mxComplexDouble *ghat, const lattice G )
{
  const int N = bandwidth;
  const size_t ld = N+1;
  const int SRightY = sym_axis[0], SRightZ = sym_axis[1];
  const int SLeftY = sym_axis[2], SLeftZ = sym_axis[3];

  // halve the orders k, l by the symmetries - a real valued ghat does not
  // even store the negative l
  const int halveK = (SRightY==2) || ((SRightY*SLeftY==2) && isReal);
  const int halveL = (SLeftY==2) || isReal;

  // quadrants of one block of degrees and of the two before, and of the block
  // D(k,j,n) = d^n(k,-j) for k = -n..n
  const int B = 4;
  const size_t ldD = 2*N+1;
  double *S = calloc((B+2)*ld*ld,sizeof(double));
  double *D = malloc(B*ld*ldD*sizeof(double));

  for (int n0 = 0; n0 <= N; n0 += B)
  {
    const int n1 = (n0+B < N+1) ? n0+B : N+1;
    for (int n = n0; n < n1; n++)
      wigner_d_quadrant_at_pi_half(N,n,S+((n+B)%(B+2))*ld*ld,S+((n+B+1)%(B+2))*ld*ld,S+(n%(B+2))*ld*ld);
    fill_wigner_d_columns(N,n0,n1,B,S,D);

    #pragma omp parallel for schedule(dynamic) if(N >= 16)
    for (int j = 0; j < n1; j++)
      for (int l = 1-n1; l < n1; l++)
      {
        if ((l-G.l0) % G.rl) continue;
        mxComplexDouble *g = ghat + (j+G.j0)*G.sj + (l-G.l0)/G.rl*G.sl;
        const int nmin = (j > abs(l)) ? j : abs(l);
        for (int n = (n0 > nmin) ? n0 : nmin; n < n1; n++)
        {
          int kmin, kmax, kstep, lmin, lmax, lstep;
          order_bounds(n,SLeftZ,halveL,isReal,&lmin,&lmax,&lstep);
          if (l < lmin || l > lmax || (l-lmin) % lstep) continue;
          order_bounds(n,SRightZ,halveK,0,&kmin,&kmax,&kstep);

          const double *d = D + ((n-n0)*ld + j)*ldD + N;   // d[k] = d^n(k,-j)
          const double dl = d[l];
          const mxComplexDouble *f = fhat + (size_t)n*(2*n-1)*(2*n+1)/3 + (l+n)*(2*n+1) + n;
          for (int k = kmin; k <= kmax; k += kstep)
          {
            if ((k-G.k0) % G.rk) continue;
            const double v = d[k] * dl;
            mxComplexDouble *gk = g + (k-G.k0)/G.rk;
            gk->real += f[k].real * v;
            gk->imag += f[k].imag * v;
          }
        }
      }
  }
  free(D);
  free(S);
}




// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  
  // variable declarations
    int bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // nrows x 1 input coefficient vector
    size_t nrows;                     // size of inCoeff
    mxDouble input_flags = 0;
    mxDouble *sym_axis;
    mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix
    
    
  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs<2)
      mexErrMsgIdAndTxt("wignerTrafomex:invalidNumInputs","More inputs are required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("wignerTrafomex:maxlhs","One output required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("wignerTrafomex:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("wignerTrafomex:notDouble","Second input argument coefficient vector must be type double.");
    // check that number of columns in second input argument (inCoeff) is 1
    if(mxGetN(prhs[1])!=1)
      mexErrMsgIdAndTxt("wignerTrafomex:inputNotVector","Second input argument coefficient vector must be a row vector.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs>=3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "wignerTrafomex:notDouble","Third input argument flags must be a scalar double.");

    // make sure the fourth input argument (sym_axis) is double (if existing)
    if( (nrhs>=4) && ( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3])!=4 ) )
      mexErrMsgIdAndTxt( "wignerTrafomex:notDouble","Fourth input argument sym_axis must be a 4x1 double vector.");


  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("wignerTrafomex:notInt","First input argument must be a natural number.");
    
    // make input matrix complex
    mxArray *zeiger = mxDuplicateArray(prhs[1]);
    if(mxMakeArrayComplex(zeiger)) {}
    
    // create a pointer to the data in the input vector (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);
    
    // get dimensions of the input vector
    nrows = mxGetM(prhs[1]);
    
    // if exists, get flags of input
    if(nrhs>=3)
      input_flags = mxGetScalar(prhs[2]);
    bool flags[7];
    get_flags(input_flags,flags);

    // if exists and the flag implies we want to use right and left 
    // symmetries to speed up --> get sym_axis of input
    double s[4] = {1,1,1,1}, ys[4];
    if( (nrhs>=4) && (flags[4]) )
      sym_axis = mxGetDoubles(prhs[3]);
    else
      sym_axis = s;

    if( ((sym_axis[0]!=sym_axis[2]) || (sym_axis[1]!=sym_axis[3])) && flags[3] )
      mexErrMsgIdAndTxt( "wignerTrafomex:notAntipodal","ODF can only be antipodal if both symmetries coincide!");


    const int makeEven = flags[1];
    const int isReal = flags[2];
    const int isAntipodal = flags[3];
    const int N = bandwidth;

  // define the lattice ghat is written to
    mwSize dims[3];
    lattice G;
    if (flags[5])
    {
      // the nfft lattice of SO3FunHarmonic/eval: only the multiples of the
      // Z-axis symmetries rk, rl, starting at -N-1 (at -1 or 0 if isReal),
      // zero padded to even length, and all orders, since ghat is not
      // reconstructed from the Y-axis symmetries afterwards
      const double *lat = (nrhs>=4) ? mxGetDoubles(prhs[3]) : sym_axis;
      const int rk = lat[1], rl = lat[3];
      const int lmin = isReal ? -((N+1) % 2) : -(N+1);
      G.k0 = -rk*((N+1)/rk);
      G.l0 = (lmin < 0 && rl == 1) ? lmin : -rl*((-lmin)/rl);
      const int nk = N/rk - G.k0/rk + 1, nl = N/rl - G.l0/rl + 1;
      dims[0] = nk + nk % 2; dims[1] = 2*N+2; dims[2] = nl + nl % 2;
      G.rk = rk; G.rl = rl; G.j0 = N+1; G.sj = dims[0]; G.sl = dims[0]*dims[1];
      ys[0] = 1; ys[1] = rk; ys[2] = 1; ys[3] = rl;
      sym_axis = ys;
    }
    else
    {
      // If f is a real valued function, then half size in 3rd dimension of
      // ghat is sufficient. Sometimes it is necessary to add zeros in some
      // dimensions to get even size for nfft.
      dims[0] = 2*N+1+makeEven;
      dims[1] = 2*N+1+makeEven;
      dims[2] = isReal ? N+1+makeEven*((N+1)%2) : 2*N+1+makeEven;
      G.k0 = -N-makeEven; G.rk = 1; G.j0 = N+makeEven; G.rl = 1;
      G.l0 = isReal ? -makeEven*((N+1)%2) : -N-makeEven;
      G.sj = dims[0]; G.sl = dims[0]*dims[1];
    }

  // create output data
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxCOMPLEX);
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);
  
  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0])
    L2_normalized_WignerD_functions(bandwidth,inCoeff);
  
  // call the computational routine
    calculate_ghat(bandwidth,inCoeff,isReal,isAntipodal,sym_axis,outFourierCoeff,G);

  // free the storage
  mxDestroyArray(zeiger);

}
