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
#ifdef _OPENMP // For parallelisation
#include <omp.h>
#endif
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include "wigner_d_recursion_at_pi_half.cpp"   // use three term recurrence relation to compute Wigner-d matrices
#include "L2_normalized_sphericalHarmonics.c"  // use L_2-normalized Spherical Harmonics by scaling the fourier coefficients



// The computational routine
template<typename T>
static void calculate_ghat( const mxDouble bandwidth, mxComplexDouble *fhat,
                            const int makeEven, const int isReal, const int isAntipodal, 
                            mxDouble *sym_axis, std::complex<T> *ghat, const mwSize nrows )
{

  // define usefull variables
    int k,l,j,n;                                   // running indices
    const int N = bandwidth;                       // integer bandwidth
         
    const int col_len = (isReal == 0)
    ? (2*N + 1 + makeEven)
    : (N + 1 + makeEven * ((N + 1) % 2));

    const int JIter = (isAntipodal == 0)
    ? 1
    : 2;


  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      // ghat[0].real = fhat[0].real;
      // ghat[0].imag = fhat[0].imag;
      ghat[0].real(fhat[0].real);
      ghat[0].imag(fhat[0].imag);
      return;
    }
    
    
  // Idea: Calculate Wigner-d matrix by recurrence formula from last two
  // Wigner-d matrices. 
  // Because of symmetry only the left parts of the rows are needed.
  //       (  A  | A'  )        + (the cross) represents row and column with index 0
  //   d = ( ----+---- )        ' corresponds to flip(.,2)
  //       (  A* | A*' )        * corresponds to flip(.,1)
    // Create 3 Wigner-d matrices for recurrence relation (2 as input and 1
    // as output). Also get an auxiliary pointer to the matrices in each case.
    std::vector<T> D_min2((2*N+1)*(N+1));
    T* wigd_min2 = D_min2.data();
    T* start_wigd_min2 = wigd_min2;

    std::vector<T> D_min1((2*N+1)*(N+1));
    T* wigd_min1 = D_min1.data();
    T* start_wigd_min1 = wigd_min1;

    std::vector<T> D((2*N+1)*(N+1));
    T* wigd = D.data();
    T* start_wigd = wigd;
    
    
    // Set start values for recurrence relations to compute Wigner-d matrices
    // Wigner_d(0,pi/2)
    wigd_min2[2*(N+1)*N] = 1;         // go to last column and center row of matrix
    
    // Wigner_d(1,pi/2)
    wigd_min1 += (2*N+1)*(N-1)+N;               // go to Wigner_d(1,pi/2) at matrixposition [-1,-1]
    const double sqrt_1_2 = sqrt(0.5);
    const double wigd_harmonicdegree1[3][3] = { // values of Wigner_d(1,pi/2)
                                                  {   0.5  ,-sqrt_1_2,  -0.5  },
                                                  {sqrt_1_2,     0   ,sqrt_1_2},
                                                  {  -0.5  ,-sqrt_1_2,   0.5  }};
    for (k=0; k<2; k++)
    {
      for (l = -1; l<=1; l++)
      {
        wigd_min1[l] = wigd_harmonicdegree1[l+1][k];  // fill with values
      }
      wigd_min1 += 2*N+1;                             // go to next column
    }
    wigd_min1 = start_wigd_min1;                      // reset pointer to matrix start
    

  // Compute ghat by iterating over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for
  // the remaining indices n > 1. It is sufficient to compute only one of 
  // the symmetric values in ghat.
  // Afterwards we fill the symmetric values of ghat insids Matlab.
    // Create pointers for help. One saves the starting position of ghat
    // and the other one saves the starting position of fhat in current
    // iteration of harmonic degree n.
    std::complex<T> *start_ghat;
    // mxComplexDouble *start_ghat;
    start_ghat = ghat;
    mxComplexDouble *iter_fhat;
    std::complex<T> *ghat00;
    // mxComplexDouble *ghat00;
    T* iter_wigd;

    // set pointer to ghat(0,0)
    ghat00 = ghat + col_len*N + (1-isReal)*N;


  // Do recursion for n = 0.
    // Write first value of fhat in ghat(0,0) , since Wigner_d(0,pi/2)=1.
    // ghat00[0] = *fhat;
    ghat00[0] = std::complex<T>(fhat->real, fhat->imag);  
    // Set pointer fhat to next harmonic degree (to the 2nd value of fhat)
    fhat ++;
    
  
  // Do recursion for n = 1.
    // jump to ghat(0,-1)
    ghat = ghat00 - col_len;
    // fill ghat with values := fhat(1,k) * d^1(j,k) * d^1(j,0)
    T value;
    for (j= -1; j<= 1; j++)
    {
      for (k= -1+isReal; k<=1; k++)
      {
        value = wigd_harmonicdegree1[j+1][-k+1] * wigd_harmonicdegree1[j+1][1];
        ghat[k] += std::complex<T>(fhat[-k+1].real, fhat[-k+1].imag) * value;
        // ghat[k].real += fhat[-k+1].real* value;
        // ghat[k].imag += fhat[-k+1].imag* value;
      }
      // jump to next column
      ghat += col_len;
    }
    // Set pointer fhat to central value of 1st harmonic degree (to the 3rd value of fhat)
    iter_fhat = fhat + 1;
    
    
    // Be shure N>1, otherwise STOP.
    if (N==1) 
      return;
    
    
    // define some usefull variables
    const int shift_tocenterwigner = (2*N+1)*N+N;

    

  // Do recursion for 1 < n <= N:
    for (n=2; n<=N; n++)
    {

      // Calculate Wigner-d matrix
      wigner_d_recursion_at_pi_half<T>(N,n,wigd_min2,wigd_min1,wigd);
      
      
      // jump to the center of Wigner-d matrix and save this position
      wigd +=  shift_tocenterwigner;
      iter_wigd = wigd;
      
      // Set pointer ghat to the central value ghat(0,0) 
      // and save this position for further iterations
      //      Note: ghat = start_ghat  would reset pointer ghat to ghat(-N,0) 
      //            if F is real valued and ghat(-N,-N) otherwise [if ghat is fullsized]
      ghat = ghat00;
      // Set pointer of fhat to the central value fhat(n,0) 
      // and save this position for further iterations
      iter_fhat = iter_fhat+2*n;
      fhat = iter_fhat;

      // Compute ghat by adding over all summands of current harmonic 
      // degree n. Therefore it is sufficient to compute ghat only for 
      // j>=0, since we have the BMC property (Double Fourier Sphere Method)
      //             ghat(j,k) = (-1)^(k) * ghat(-j,k).
      // Moreover we have additional symmetry properties if 
      //    - S2FunHarmonic is real valued
      //    - S2FunHarmonic is antipodal (fhat=0 for odd degrees n)
      // we use them by only computing one of the symmetric coefficients 
      // and skipping zeros.
      if((isAntipodal==0) || (n%2==0)){
        
        // Iteration:
        // The Wigner-d functions satisfy the symmetry property
        //          d_n(j,k)*d_n(j,l) = d_n(k,-j)*d_n(l,-j)
        // in MTEX. We use this in the following.
        #pragma omp parallel for firstprivate(ghat,fhat,wigd) private(value)        // Parallelization
        for (j= 0; j<=n; j+=JIter)
        {
          // jump to actual column --> ghat(0,j)
          ghat = ghat00 + j*col_len;
          // use column -j of the Wigner-d matrix
          wigd = iter_wigd - j*(2*N+1);

          for (k= -n*(1-isReal); k<=n; k++)
          {
            // compute value
            value = wigd[-k]*wigd[0];

            // set value
            ghat[k] += std::complex<T>(fhat[-k].real, fhat[-k].imag) * value;
            // ghat[k].real += fhat[-k].real*value;
            // ghat[k].imag += fhat[-k].imag*value;
          }
        }

      }
      
      // permute the pointers (wigd, wigdmin1 and wigdmin2) for the next
      // recursions step for the calculation of the Wigner-d matrices.
      // Therefore the two most recently computed Wigner-d matrices are
      // preserved for next recursion step.
      // The other matrix will be overwritten in the next step.
      // Use wigd as exchange variable.
      wigd = start_wigd_min2;
      
      start_wigd_min2 = start_wigd_min1;
      start_wigd_min1 = start_wigd;
      start_wigd = wigd;
      
      wigd_min1 = start_wigd_min1;
      wigd_min2 = start_wigd_min2;
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
    mxDouble *sym_axis;
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

    // if exists and the flag implies we want to use the symmetry to 
    // speed up --> get sym_axis of input
    double s[2] = {1,1};
    if( (nrhs>=4) && (flags[4]) )
      sym_axis = mxGetDoubles(prhs[2]);
    else
      sym_axis = s;

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
      // TODO: evt. muss outFourierCOeff erst im long double gerechnet werden und später auf double transformiert und dann zurückgegeben werden.
      std::vector<std::complex<long double>> ghat_tmp(dims[0]*dims[1]);
      calculate_ghat<long double>(bandwidth,inCoeff,makeEven,isReal,isAntipodal,sym_axis,ghat_tmp.data() + start_shift,(mwSize)nrows);
      for (size_t i = 0; i < dims[0]*dims[1]; i++) {
        outFourierCoeff[i].real = static_cast<double>(ghat_tmp[i].real());
        outFourierCoeff[i].imag = static_cast<double>(ghat_tmp[i].imag());
      }
      // mexWarnMsgIdAndTxt("sphericalHarmonicTrafomex:precisionLoss","Precision loss: using long double format since N > 1023.");
    }
    else{
      std::vector<std::complex<double>> ghat_tmp(dims[0]*dims[1]);
      // std::complex<double> *g = ghat_tmp.data() + start_shift;
      calculate_ghat<double>(bandwidth,inCoeff,makeEven,isReal,isAntipodal,sym_axis,ghat_tmp.data() + start_shift,(mwSize)nrows);
      for (size_t i = 0; i < dims[0]*dims[1]; i++) {
        outFourierCoeff[i].real = ghat_tmp[i].real();
        outFourierCoeff[i].imag = ghat_tmp[i].imag();
      }
    }

  // free the storage
  mxDestroyArray(zeiger);

}
