/*=========================================================================
 * sphericalHarmonicTrafoAdjointmex.c - quadrature of S2FunHarmonic
 * 
 * The input is a 3-tensor, that is received by the inverse nfft(2) respecting
 * spherical coordinates of evaluations of a spherical function (F).
 * We calculate as output the corresponding spherical harmonic coefficient vector 
 * (fhat) of this function F.
 * Therefore we use symmetry properties of F to calculate only a part of symmetrical
 * harmonic coefficients and to speed up the algorithm. The following 
 * symmetry properties are implemented:
 * 1) Possibly the size of the input was made even in any dimension by
 * adding zeros in front. That was necessary since inverse nfft was done for 
 * indices -N-1 : N but the values were given for indices -N:N.
 * 2) The BMC property (Double Fourier Sphere Method) yields
 *                ghat(k,j) = (-1)^(k) ghat(k,-j).
 * 3) If F is a real valued function, the harmonic coefficients satisfy
 * the symmetry property
 *                     fhat(n,k) = conj(fhat(n,-k)). 
 * where conj denotes the conjugate complex. Hence we get
 *            ghat(k,j) = (-1)^(k) * conj(ghat(-k,j)).
 * 4) If F is an antipodal function, the spherical Fourier coefficients 
 * satisfy the symmetry property
 *                   fhat(n,k) = 0 , if n is odd.
 * Hence we have
 *              ghat(k,j) = (-1)^(k) * ghat(-k,j).
 *
 * For the calculation of fhat we need Wigner-d matrices in theta = pi/2. 
 * From symmetry properties of this Wigner-d matrices we get
 *       (-1)^(k+l) * d^n(l,k) = d^n(k,l) = (-1)^(n+k+l) * d^n(k,-l).
 * We use this to speed up the calculation of fhat.
 * 
 * Syntax
 *   flags = 2^0+2^2+2^3;
 *   fhat = wignerTrafoAdjointmex(N,ghat,flags,[1,1]);
 * 
 * Input
 *  N        - bandwidth
 *  ghat     - matrix of fourier transformed function evaluations on ClenshawCurtis grid
 *  flags    - 2^0 -> use L_2-normalized spherical harmonics
 *             2^1 -> use input of even size            (not implemented yet)
 *             2^2 -> fhat are the fourier coefficients of a real valued function
 *             2^3 -> fhat are the fourier coefficients of a antipodal function
 *             2^4 -> use right and left symmetry       (not implemented yet)
 *
 * Output
 *  fhat - SO(3) Fourier coefficient vector
 *
 *
 * This is a MEX-file for MATLAB.
 * 
 *=======================================================================*/

#include <mex.h>
#include <cmath>
#include <matrix.h>
#include <cstdio>
#include <complex>
#include <cstring>
#ifdef _OPENMP // For parallelisation
#include <omp.h>
#endif
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include <algorithm>
#include <vector>
#include "wigner_d_quadrant_at_pi_half.cpp"   // three term recurrence relation for the Wigner-d matrices at pi/2
#include "L2_normalized_sphericalHarmonics.c"  // use L_2-normalized spherical hamronics by scaling the fourier coefficients



// The computational routine
//   fhat(n,-k) = sum_{j=0}^n H(k,j) d^n(k,-j) d^n(0,-j),
//   H(k,0) = ghat(k,0),  H(k,j) = ghat(k,j) + (-1)^k ghat(k,-j),
// for k = -n..n, or k = 0..n if isReal. Only even n+j contribute, and for them
//   d^n(k,-j) d^n(0,-j) = S(j,|k|) S(j,0) * (-1)^|k| if k < 0
// with the quadrant S(a,b) = d^n(-a,-b), whose columns are contiguous. The
// rows of H are formed once, and every row takes a whole block of degrees.
static void calculate_ghat_adjoint( const mxDouble bandwidth, mxComplexDouble *ghat,
                          const int isReal, const int isAntipodal,
                          std::complex<double> *fhat)
{
  const int N = bandwidth;
  const size_t ld = N+1;
  const int row_len = 2*N+1;
  const int K_min = isReal ? 0 : -N;

  // ghat(k,j) at center[k + j*row_len]
  const mxComplexDouble *center = ghat + N*(row_len+1);

  // H(k,j) at H[(k+N)*ld + j]
  std::vector<std::complex<double>> H((size_t)row_len*ld);
  #pragma omp parallel for if(N >= 64)
  for (int k = K_min; k <= N; k++)
  {
    std::complex<double> *h = H.data() + (size_t)(k+N)*ld;
    const double pm = (k % 2) ? -1 : 1;
    h[0] = std::complex<double>(center[k].real,center[k].imag);
    for (int j = 1; j <= N; j++)
    {
      const mxComplexDouble &a = center[k + j*row_len], &b = center[k - j*row_len];
      h[j] = std::complex<double>(a.real + pm*b.real,a.imag + pm*b.imag);
    }
  }

  // quadrants of one block of degrees and of the two before
  const int B = 4;
  std::vector<double> S((B+2)*ld*ld, 0);
  auto quadrant = [&](int n) { return S.data() + (n % (B+2))*ld*ld; };

  WignerQuadrants W(N);
  for (int n0 = 0; n0 <= N; n0 += B)
  {
    const int n1 = std::min(n0+B,N+1);
    for (int n = n0; n < n1; n++)
      W.next(n,n>=2 ? quadrant(n-2) : nullptr,n>=1 ? quadrant(n-1) : nullptr,quadrant(n));

    #pragma omp parallel for schedule(dynamic) if(N >= 64)
    for (int k = std::max(K_min,1-n1); k < n1; k++)
    {
      const int ka = std::abs(k);
      const std::complex<double> *h = H.data() + (size_t)(k+N)*ld;
      for (int n = std::max(n0,ka); n < n1; n++)
      {
        if (isAntipodal && n % 2) continue;
        const double *dk = quadrant(n) + ka*ld, *d0 = quadrant(n);
        std::complex<double> sum = 0;
        for (int j = n % 2; j <= n; j += 2)
          sum += h[j] * (dk[j]*d0[j]);
        fhat[n*n + n - k] = (k < 0 && ka % 2) ? -sum : sum;
      }
    }
  }
}




// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  
  // variable declarations
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // input coefficient 3-tensor
    mxDouble input_flags = 0;
    mxComplexDouble *outFourierCoeff; // output fourier coefficient vector
    
  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs<2)
      mexErrMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:invalidNumInputs","More inputs are required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:maxlhs","One output is required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:notDouble","Second input argument coefficient array must be type double.");
    // check that second input argument (inCoeff) is 2-dimensional array or just one value (if N==0)
    const bool single_value = ( (mxGetM(prhs[1])==1) && (mxGetN(prhs[1])==1) && (mxGetScalar(prhs[0])==0) );
    if(  (mxGetNumberOfDimensions(prhs[1])!=2) && (!single_value)  )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:inputNotTensor","Second input argument coefficient array must be a 2-tensor.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs>=3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "sphericalHarmonicTrafoAdjointmex:notDouble","Third input argument flags must be a scalar double.");

    // get dimensions of the input 2-tensor
    const mwSize *dims = mxGetDimensions(prhs[1]);
    if( (dims[0]!=dims[1]) )
      mexErrMsgIdAndTxt( "sphericalHarmonicTrafoAdjointmex:falseDim","Second input argument coefficient array needs same length in each dimension.");

    // make sure the fourth input argument (sym_axis) is double (if existing)
    if( (nrhs>=4) && ( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3])!=2 ) )
      mexErrMsgIdAndTxt( "sphericalHarmonicTrafoAdjointmex:notDouble","Fourth input argument sym_axis must be a 2x1 double vector.");

    
  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:notInt","First input argument must be a natural number.");
    
    // make input 2-tensor complex
    mxArray *zeiger = mxDuplicateArray(prhs[1]);
    if(mxMakeArrayComplex(zeiger)) {}
    
    // create a pointer to the data in the input 2-tensor (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);
    
    // if exists, get flags of input
    if(nrhs>=3)
      input_flags = mxGetScalar(prhs[2]);
    bool flags[7];
    get_flags(input_flags,flags);

    // The fourth argument (sym_axis) is still accepted and type checked above
    // for callers that pass it, but the symmetry flag 2^4 is not implemented:
    // calculate_ghat_adjoint never dereferenced sym_axis, it only carried it
    // around. Dropped rather than left as a trap.

    
    const int isReal = flags[2];
    const int isAntipodal = flags[3];


  // create output data
    const int deg2dim = (bandwidth+1)*(bandwidth+1);
    plhs[0] = mxCreateNumericMatrix(deg2dim, 1, mxDOUBLE_CLASS, mxCOMPLEX);

    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);


  // call the computational routine
    std::vector<std::complex<double>> ghat_tmp(deg2dim);
    calculate_ghat_adjoint(bandwidth,inCoeff,isReal,isAntipodal,ghat_tmp.data());
    for (size_t i = 0; i < (size_t)deg2dim; ++i) {
      outFourierCoeff[i].real = ghat_tmp[i].real();
      outFourierCoeff[i].imag = ghat_tmp[i].imag();
    }

  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0])
    L2_normalized_sphericalHarmonics(bandwidth,outFourierCoeff);

  // free the storage
  mxDestroyArray(zeiger);

}
