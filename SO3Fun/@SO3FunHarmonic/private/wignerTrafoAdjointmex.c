/*=========================================================================
 * wignerTrafoAdjointmex.c - quadrature of SO3FunHarmonic
 * 
 * The input is a 3-tensor, that is received by the inverse nfft(3) respecting
 * the Euler angles of evaluations of a SO(3) function (F).
 * We calculate as output the corresponding SO(3) fourier coefficient vector 
 * (fhat) of this function F.
 * Therefore we use symmetry properties of F to calculate only a part of symmetrical
 * SO(3) Fourier coefficients and to speed up the algorithm. The following 
 * symmetry properties are implemented:
 * 1) Possibly the size of the input was made even in any dimension by
 * adding zeros in front. That was necessary since inverse nfft was done for 
 * indices -N-1 : N but the values were given for indices -N:N.
 * 2) If F is a real valued function, the SO(3) Fourier coefficients satisfy
 * the symmetry property
 *                     fhat(n,k,l) = conj(fhat(n,-k,-l)). 
 * 3) If F is an antipodal function, the SO(3) Fourier coefficients satisfy
 * the symmetry property
 *                     fhat(n,k,l) = fhat(n,-l,-k). 
 * 4) Similarly an r-fold symmetry axis along the Z-axis in right or left 
 * symmetry implies that the SO(3) Fourier coefficients satisfy
 *                    fhat(n,k,l) = 0   if k mod r is not 0
 * or
 *                    fhat(n,k,l) = 0   if l mod r is not 0.
 * Moreover an 2-fold symmetry along Y-axis yields 
 *            fhat(n,k,l) = (-1)^n fhat(n,-k,l)
 * for right symmetry and
 *            fhat(n,k,l) = (-1)^n fhat(n,k,-l)
 * in case of left symmetry.
 *
 *
 * For the calculation of fhat we need Wigner-d matrices with Euler angle
 * beta = pi/2. From symmetry properties of this Wigner-d matrices we get
 *       (-1)^(k+l) * d^n(l,k) = d^n(k,l) = (-1)^(n+k+l) * d^n(k,-l).
 * We use this to speed up the calculation of fhat.
 * 
 * Syntax
 *   flags = 2^0+2^2+2^4;
 *   sym_axis = [1,2,2,1];
 *   fhat = wignerTrafoAdjointmex(N,ghat,flags,sym_axis);
 * 
 * Input
 *  N        - bandwidth
 *  ghat     - matrix of fourier transformed function evaluations on ClenshawCurtis grid
 *  flags    - 2^0 -> use L_2-normalized Wigner-D functions
 *             2^1 -> use input of even size            (not implemented yet)
 *             2^2 -> fhat are the fourier coefficients of a real valued function
 *             2^3 -> antipodal
 *             2^4 -> use right and left symmetry
 *  sym_axis - vector [SRight-Y,SRight-Z,SLeft-Y,SLeft-Z] where SRight-Y,SLeft-Y are in {1,2} and 
 *             SRight-Z,SLeft-Z are in {1,2,3,4,6} and describes the countability of the symmetry axis
 *
 * Output
 *  fhat - SO(3) Fourier coefficient vector
 *
 *
 * This is a MEX-file for MATLAB.
 * 
 *=======================================================================*/

#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <stdio.h>
#include <complex.h>
#include <string.h>
#ifdef _OPENMP // For parallelisation
#include <omp.h>
#endif
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include "wigner_d_quadrant_at_pi_half.c"   // three term recurrence relation for the Wigner-d matrices at pi/2
#include "L2_normalized_WignerD_functions.c"  // use L_2-normalized Wigner-D functions by scaling the fourier coefficients



// loop bounds of the orders k (right, rZ-fold) or l (left) of degree n, halve
// drops the positive ones; degrees 0 and 1 ignore the symmetries
static void order_bounds(int n, int rZ, int halve, int *min, int *max, int *step)
{
  if (n <= 1) { *min = -n; *max = n; *step = 1; return; }
  *min = -n + n % rZ;
  *max = n - n % rZ;
  *step = rZ;
  if (halve) *max = 0;
}

// Where ghat(k,j,l) is stored: at base[(k-k0)/rk + (j+j0)*sj + (l-l0)/rl*sl]
// for the multiples k-k0 of rk and l-l0 of rl, all other entries are zero
typedef struct { int k0, rk, j0, l0, rl; size_t sj, sl; } lattice;

// The computational routine
//   fhat(n,k,l) = sum_{j=0}^n H(k,j,l) d^n(k,-j) d^n(l,-j),
//   H(k,0,l) = ghat(k,0,l),  H(k,j,l) = ghat(k,j,l) + (-1)^(k+l) ghat(k,-j,l),
// with the quadrant S(a,b) = d^n(-a,-b), from which
//   d^n(k,-j) = S(-k,j) for k <= 0,  (-1)^(n+k+j) S(k,j) for k > 0.
// The Wigner-d matrices of a block of degrees are computed first and then
// every pair of rows ghat(:,+-j,l) goes into the whole block.
static void calculate_ghat_adjoint( const mxDouble bandwidth, const mxComplexDouble *ghat,
                          const int isReal, const int isAntipodal, mxDouble *sym_axis,
                          mxComplexDouble *fhat, const lattice G)
{
  const int N = bandwidth;
  const size_t ld = N+1;
  const int SRightY = sym_axis[0], SRightZ = sym_axis[1];
  const int SLeftY = sym_axis[2], SLeftZ = sym_axis[3];
  const int SY = SRightY*SLeftY;

  // halve the orders k, l by the symmetries - see the flags above
  const int halveK = (SRightY==2) || ((SY==2) && isReal) || ((SY==1) && isReal && !isAntipodal);
  const int halveL = (SLeftY==2) || ((SY==2) && isReal);

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
    for (int l = 1-n1; l < n1; l++)
      for (int j = 0; j < n1; j++)
      {
        if ((l-G.l0) % G.rl) continue;
        const mxComplexDouble *gp = ghat + (j+G.j0)*G.sj + (l-G.l0)/G.rl*G.sl - G.k0;
        const mxComplexDouble *gm = ghat + (G.j0-j)*G.sj + (l-G.l0)/G.rl*G.sl - G.k0;
        const int nmin = (j > abs(l)) ? j : abs(l);
        for (int n = (n0 > nmin) ? n0 : nmin; n < n1; n++)
        {
          int kmin, kmax, kstep, lmin, lmax, lstep;
          order_bounds(n,SLeftZ,halveL,&lmin,&lmax,&lstep);
          if (l < lmin || l > lmax || (l-lmin) % lstep) continue;
          order_bounds(n,SRightZ,halveK,&kmin,&kmax,&kstep);
          if (n > 1 && isAntipodal)
          {
            if (SY==1) { kmax = -l; if (isReal) kmin = l; }
            if (SY==4) kmin = l;
          }

          const double *d = D + ((n-n0)*ld + j)*ldD + N;   // d[k] = d^n(k,-j)
          const double dl = d[l];
          mxComplexDouble *f = fhat + (size_t)n*(2*n-1)*(2*n+1)/3 + (l+n)*(2*n+1) + n;
          for (int k = kmin; k <= kmax; k += kstep)
          {
            if ((k-G.k0) % G.rk) continue;
            const int i = G.k0 + (k-G.k0)/G.rk;   // gp[i], gm[i] hold order k
            const double v = d[k] * dl;
            if (j == 0)
            {
              f[k].real += gp[i].real * v;
              f[k].imag += gp[i].imag * v;
            }
            else
            {
              const double pm = ((k+l) & 1) ? -v : v;
              f[k].real += gp[i].real * v + gm[i].real * pm;
              f[k].imag += gp[i].imag * v + gm[i].imag * pm;
            }
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
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // input coefficient 3-tensor
    mxDouble input_flags = 0;
    mxDouble *sym_axis;
    mxComplexDouble *outFourierCoeff; // output fourier coefficient vector
    
  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs<2)
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:invalidNumInputs","More inputs are required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:maxlhs","One output is required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:notDouble","Second input argument coefficient array must be type double.");
    // check that second input argument (inCoeff) is 3-dimensional array or just one value (if N==0)
    const bool single_value = ( (mxGetM(prhs[1])==1) && (mxGetN(prhs[1])==1) && (mxGetScalar(prhs[0])==0) );
    if(  (mxGetNumberOfDimensions(prhs[1])!=3) && (!single_value)  )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:inputNotTensor","Second input argument coefficient array must be a 3-tensor.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs>=3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:notDouble","Third input argument flags must be a scalar double.");

    // make sure the fourth input argument (sym_axis) is double (if existing)
    if( (nrhs>=4) && ( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3])!=4 ) )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:notDouble","Fourth input argument sym_axis must be a 4x1 double vector.");

    
  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:notInt","First input argument must be a natural number.");
    
    // the input 3-tensor is only read, so a complex one is used in place
    mxArray *zeiger = mxIsComplex(prhs[1]) ? NULL : mxDuplicateArray(prhs[1]);
    if (zeiger) mxMakeArrayComplex(zeiger);
    inCoeff = mxGetComplexDoubles(zeiger ? zeiger : prhs[1]);
    
    // if exists, get flags of input
    if(nrhs>=3)
      input_flags = mxGetScalar(prhs[2]);
    bool flags[7];
    get_flags(input_flags,flags);

    // if exists and the flag implies we want to use right and left 
    // symmetries to speed up --> get sym_axis of input
    double s[4] = {1,1,1,1};
    if( (nrhs>=4) && (flags[4]) )
      sym_axis = mxGetDoubles(prhs[3]);
    else
      sym_axis = s;

    if( ((sym_axis[0]!=sym_axis[2]) || (sym_axis[1]!=sym_axis[3])) && flags[3] )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:notAntipodal","ODF can only be antipodal if both symmetries coincide!");

    
    const int isReal = flags[2];
    const int isAntipodal = flags[3];
    const int N = bandwidth;

  // the lattice ghat is read from - with flag 2^5 the nfft lattice of
  // SO3FunHarmonic/adjoint, i.e. only the multiples of the Z-axis symmetries
  // rk, rl, starting at -N-1 and zero padded to even length, otherwise the
  // full (2N+1)^3 tensor
    lattice G;
    mwSize len[3];
    if (flags[5])
    {
      const int rk = sym_axis[1], rl = sym_axis[3];
      G.k0 = -rk*((N+1)/rk); G.l0 = -rl*((N+1)/rl);
      const int nk = N/rk - G.k0/rk + 1, nl = N/rl - G.l0/rl + 1;
      len[0] = nk + nk % 2; len[1] = 2*N+2; len[2] = nl + nl % 2;
      G.rk = rk; G.rl = rl; G.j0 = N+1;
    }
    else
    {
      len[0] = len[1] = len[2] = 2*N+1;
      G.k0 = G.l0 = -N; G.rk = G.rl = 1; G.j0 = N;
    }
    G.sj = len[0]; G.sl = len[0]*len[1];
    if( mxGetNumberOfElements(prhs[1]) != len[0]*len[1]*len[2] || mxGetM(prhs[1]) != len[0] )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:falseDim","Second input argument coefficient array must have size %dx%dx%d.",
        (int)len[0],(int)len[1],(int)len[2]);


  // create output data
    const int deg2dim = (bandwidth+1)*(2*bandwidth+1)*(2*bandwidth+3)/3;
    plhs[0] = mxCreateNumericMatrix(deg2dim, 1, mxDOUBLE_CLASS, mxCOMPLEX);

    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);


  // call the computational routine
    calculate_ghat_adjoint(bandwidth,inCoeff,isReal,isAntipodal,sym_axis,outFourierCoeff,G);

  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0])
    L2_normalized_WignerD_functions(bandwidth,outFourierCoeff);

  // free the storage
  if (zeiger) mxDestroyArray(zeiger);

}
