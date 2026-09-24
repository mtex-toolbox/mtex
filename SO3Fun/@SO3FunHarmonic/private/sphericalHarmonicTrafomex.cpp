/*=========================================================================
 * SphericalHarmonicTrafomex.c - eval of S2FunHarmonic
 * 
 * The inputs are the spherical fourier coefficients (fhat) of the harmonic 
 * representation of a S^2 function S2F and the bandwidth (N).
 * This harmonic representation will be transformed to a FFT(2) in terms
 * of spherical coordinates.
 * We calculate as output the corresponding fourier coefficient matrix up to
 * a multiplicative constant i^(k). That means:
 * The SphericalHarmonicTrafomex function just computes
 * $$\hat{g}_{k,j} = \sum_{n = \max \{|j|,|k|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k} \, d_n^{j,k}(0) \, d_n^{j,0}(0)$$
 * from the spherical coefficients $\hat{f}_n^{k}$.
 *
 * We will use symmetry properties of S2F to calculate only a part of
 * symmetrical spherical coefficients and to speed up the algorithm. 
 * The following symmetry properties are implemented:
 * 1) The BMC property (Double Fourier Sphere Method) yields
 *                ghat(k,j) = (-1)^(k) ghat(k,-j).
 * 2) If S2F is a real valued function, the spherical Fourier coefficients 
 * satisfy the symmetry property
 *                     fhat(n,k) = conj(fhat(n,-k))
 * where conj denotes the conjugate complex. Hence we get
 *            ghat(k,j) = (-1)^(k) * conj(ghat(-k,j)).
 * Moreover we can half the following FFT(2) to (-N:N)x(0:N). 
 * Therefore ghat(:,0) has to be halved.
 * 3) If SO3F is an antipodal function, the spherical Fourier coefficients 
 * satisfy the symmetry property
 *                   fhat(n,k) = 0 , if n is odd.
 * Hence we have
 *              ghat(k,j) = (-1)^(k) * ghat(-k,j).
 *
 * It is also possible to calculate ghat with even size in any dimension by
 * using the flag 2^1. Therefore zeros are added in front of the output 
 * 3-tensor. That is necessary since the nfft is done for indices -N-1 : N 
 * but the values are given for indices -N:N.
 *
 *
 * Syntax
 *   flags = 2^0+2^2;
 *   ghat = SphHarmTrafomex(N,fhat,flags,sym_axis);
 * 
 * Input
 *  N        - bandwidth
 *  fhat     - SO(3) Fourier coefficient vector
 *  flags    - double where:
 *             2^0 -> use L_2-normalized Spherical Harmonics
 *             2^1 -> make size of result even
 *             2^2 -> fhat are the fourier coefficients of a real valued function
 *             2^3 -> antipodal            
 *             2^4 -> use right and left symmetry       (not implemented yet)
 *
 * Output
 *  ghat - up to a constant DFS transformed spherical Fourier coefficients
 *
 *
 * This is a MEX-file for MATLAB.
 * 
 *=======================================================================*/

#include <mex.h>
#include <cmath>
#include <matrix.h>
#include <cstdio>    // For printf
#include <complex>
#include <cstring>
#include <limits>
#ifdef _OPENMP // For parallelisation
#include <omp.h>
#endif
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include <algorithm>
#include <vector>
#include "wigner_d_quadrant_at_pi_half.cpp"   // three term recurrence relation for the Wigner-d matrices at pi/2
#include "L2_normalized_sphericalHarmonics.c"  // use L_2-normalized Spherical Harmonics by scaling the fourier coefficients



// The computational routine
//   ghat(k,j) = sum_n fhat(n,-k) d^n(-k,-j) d^n(0,-j)
// for j = 0..N and k = -N..N, or k = 0..N if isReal. Only even n+j contribute,
// since d^n(0,-j) = 0 otherwise. The Wigner-d matrices of a block of degrees
// are computed first and then every column of ghat takes the whole block,
// which keeps the column in cache.
template<typename T>
static void calculate_ghat( const mxDouble bandwidth, mxComplexDouble *fhat,
                            const int makeEven, const int isReal, const int isAntipodal,
                            std::complex<T> *ghat )
{
  const int N = bandwidth;
  const size_t ld = N+1;
  const int col_len = (isReal == 0)
    ? (2*N + 1 + makeEven)
    : (N + 1 + makeEven * ((N + 1) % 2));

  // ghat(0,0), columns j = 0..N follow with stride col_len
  std::complex<T> *ghat00 = ghat + col_len*N + (1-isReal)*N;

  // quadrants S(a,b) = d^n(-a,-b) of one block of degrees and of the two before
  const int B = 4;
  std::vector<T> S((B+2)*ld*ld, 0);
  auto quadrant = [&](int n) { return S.data() + (n % (B+2))*ld*ld; };

  for (int n0 = 0; n0 <= N; n0 += B)
  {
    const int n1 = std::min(n0+B,N+1);
    for (int n = n0; n < n1; n++)
      wigner_d_quadrant_at_pi_half<T>(N,n,n>=2 ? quadrant(n-2) : nullptr,n>=1 ? quadrant(n-1) : nullptr,quadrant(n));

    #pragma omp parallel for schedule(dynamic) if(N >= 64)
    for (int j = 0; j < n1; j++)
    {
      std::complex<T> *g = ghat00 + (size_t)j*col_len;
      for (int n = std::max(n0,j); n < n1; n++)
      {
        if ((n+j) % 2 || (isAntipodal && n % 2)) continue;
        const T *d = quadrant(n) + j*ld;          // d[k] = d^n(-k,-j)
        const mxComplexDouble *f = fhat + n*n + n; // f[m] = fhat(n,m)
        for (int k = 0; k <= n; k++)
          g[k] += std::complex<T>(f[-k].real,f[-k].imag) * (d[k]*d[0]);
        // rows -k: d^n(k,-j) = (-1)^k d^n(-k,-j) for even n+j
        if (!isReal)
          for (int k = 1; k <= n; k++)
            g[-k] += std::complex<T>(f[k].real,f[k].imag) * ((k % 2 ? -d[k] : d[k])*d[0]);
      }
    }
  }
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
    mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix
    
    
  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs<2)
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:invalidNumInputs","More inputs are required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:maxlhs","One output required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:notDouble","Second input argument coefficient vector must be type double.");
    // check that number of columns in second input argument (inCoeff) is 1
    if(mxGetN(prhs[1])!=1)
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:inputNotVector","Second input argument coefficient vector must be a row vector.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs>=3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "sphericalHarmonicTrafomex:notDouble","Third input argument flags must be a scalar double.");

    // make sure the fourth input argument (sym_axis) is double (if existing)
    if( (nrhs>=4) && ( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3])!=2 ) )
      mexErrMsgIdAndTxt( "sphericalHarmonicTrafomex:notDouble","Fourth input argument sym_axis must be a 2x1 double vector.");


  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:notInt","First input argument must be a natural number.");
    
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

    // (N+1)^2 coefficients are required, and L2_normalized_sphericalHarmonics
    // below *writes* exactly that many - so a short vector is a heap overflow
    // before the transform even starts. A longer one is legitimate:
    // sphericalHarmonicTrafo.m passes the whole fhat and lets N truncate.
    if( (double)nrows < (bandwidth+1.0)*(bandwidth+1.0) )
      mexErrMsgIdAndTxt("sphericalHarmonicTrafomex:coefficientVectorTooShort",
        "Bandwidth %d needs at least %.0f coefficients, got %.0f.",
        bandwidth,(bandwidth+1.0)*(bandwidth+1.0),(double)nrows);

    // The fourth argument (sym_axis) is still accepted and type checked above
    // for callers that pass it, but the symmetry flag 2^4 is not implemented:
    // calculate_ghat never dereferenced sym_axis, it only carried it around.
    // The pointer was moreover taken from prhs[2] - the scalar flags - rather
    // than prhs[3], so implementing 2^4 on top of it would have read two
    // doubles out of a one element array. Dropped rather than repaired.

    const int makeEven = flags[1];
    const int isReal = flags[2];
    const int isAntipodal = flags[3];

  
  // define length of the 2 dimensions of ghat
    // If f is a real valued function, then half size in 2nd dimension of
    // ghat is sufficient. Sometimes it is necessary to add zeros in some
    // dimensions to get even size for nfft.
    mwSize dims[2];
    dims[1] = 2*bandwidth+1+makeEven;
    int start_shift;
    if (isReal == 0){
      dims[0] = 2*bandwidth+1+makeEven;
      start_shift = makeEven*(dims[0] + 1);
    }
    else if (bandwidth % 2 == 0){
      dims[0] = bandwidth+1+makeEven;
      start_shift = makeEven*(dims[0] + 1);
    }
    else{
      dims[0] = bandwidth+1;
      start_shift = makeEven*dims[0];
    }
    
 
  // create output data
    plhs[0] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxCOMPLEX);
    
    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);
    // set pointer to skip first index
    // outFourierCoeff += start_shift;
    
  
  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0]){
    L2_normalized_sphericalHarmonics(bandwidth,inCoeff);
  }
  
  // call the computational routine
    if (bandwidth > 1023){
      // The Wigner-d recursion seeds every entry with a value as small as
      // 2^(-n) and a seed that underflows stays zero for all higher degrees,
      // so what limits the bandwidth is the exponent range of the type the
      // matrices are stored in (see wigner_d_recursion_at_pi_half.cpp).
      // long double buys that range only where the ABI makes it wider than
      // double - it does on x86 (80 bit, n up to about 16000) and with
      // MinGW-w64, but on Apple silicon long double *is* double. Say so
      // instead of returning silently wrong coefficients.
      if (bandwidth > -std::numeric_limits<long double>::min_exponent-1)
        mexWarnMsgIdAndTxt("sphericalHarmonicTrafomex:bandwidthTooLarge",
          "long double is too narrow on this platform to represent the Wigner-d "
          "functions up to bandwidth %d - the result is inaccurate.",bandwidth);
      std::vector<std::complex<long double>> ghat_tmp(dims[0]*dims[1]);
      calculate_ghat<long double>(bandwidth,inCoeff,makeEven,isReal,isAntipodal,ghat_tmp.data() + start_shift);
      for (size_t i = 0; i < dims[0]*dims[1]; i++) {
        outFourierCoeff[i].real = static_cast<double>(ghat_tmp[i].real());
        outFourierCoeff[i].imag = static_cast<double>(ghat_tmp[i].imag());
      }
      // mexWarnMsgIdAndTxt("sphericalHarmonicTrafomex:precisionLoss","Precision loss: using long double format since N > 1023.");
    }
    else{
      std::vector<std::complex<double>> ghat_tmp(dims[0]*dims[1]);
      // std::complex<double> *g = ghat_tmp.data() + start_shift;
      calculate_ghat<double>(bandwidth,inCoeff,makeEven,isReal,isAntipodal,ghat_tmp.data() + start_shift);
      for (size_t i = 0; i < dims[0]*dims[1]; i++) {
        outFourierCoeff[i].real = ghat_tmp[i].real();
        outFourierCoeff[i].imag = ghat_tmp[i].imag();
      }
    }

  // free the storage
  mxDestroyArray(zeiger);

}
