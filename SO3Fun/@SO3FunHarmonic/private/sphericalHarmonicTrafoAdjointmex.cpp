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
#include "wigner_d_recursion_at_pi_half.cpp"   // use three term recurrence relation to compute Wigner-d matrices
#include "L2_normalized_sphericalHarmonics.c"  // use L_2-normalized spherical hamronics by scaling the fourier coefficients



// The computational routine
template<typename T>
static void calculate_ghat_adjoint( const mxDouble bandwidth, mxComplexDouble *ghat,
                          const int isReal, const int isAntipodal, mxDouble *sym_axis,
                          std::complex<T> *fhat)
{

  // define usefull variables
    int k,l,j,n;                                      // running indices
    const int N = bandwidth;                          // integer bandwidth
    const int row_len = (2*N+1);                      // length of a row and a column in ghat
            
  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      // (*fhat).real = (*ghat).real;
      // (*fhat).imag = (*ghat).imag;
      fhat[0].real(ghat[0].real);
      fhat[0].imag(ghat[0].imag);
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
      for (l= -1; l<=1; l++)
      {
        wigd_min1[l] = wigd_harmonicdegree1[l+1][k];  // fill with values
      }
      wigd_min1 += 2*N+1;                             // go to next column
    }
    wigd_min1 = start_wigd_min1;                      // reset pointer to matrix start
    
  // Compute fhat by iterating over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for
  // the remaining indices n > 1.
    // Create pointer that saves the position ghat(0,0)
    mxComplexDouble *center_ghat;
    center_ghat = ghat + N*(row_len+1);

  // Do step n = 0.
    // Write ghat(0,0) in fhat(1), since Wigner_d(0,pi/2) = 1.
    ghat = center_ghat;
    // *fhat = *ghat;
    fhat[0] = std::complex<T>(ghat->real, ghat->imag);  
    // Set pointer fhat to next harmonic degree (to the 2nd value of fhat)
    fhat +=3;
    
  // Do step n = 1, without use of symmetry
    // jump to ghat(-1,0)
    ghat --;

    // fill fhat with values fhat(n,-k) = sum_{j=-n}^n ghat(k,j) * d^1(j,k) * d^1(j,0)
    T value;
    for (k= -1; k<=1; k++)
    {
      for (j= -1; j<=1; j++)
      {
        value = wigd_harmonicdegree1[k+1][-j+1] * wigd_harmonicdegree1[1][-j+1];
        fhat[0] += std::complex<T>(ghat[j*row_len].real, ghat[j*row_len].imag) * value;
        // (*fhat).real += ghat[j*row_len].real* value;
        // (*fhat).imag += ghat[j*row_len].imag* value;

      }
      // jump to next row
      fhat --;
      ghat ++;
    }

    // Be shure N>1, otherwise STOP.
    if (N==1)
      return;
    
    
  // define some usefull variables
    const int shift_tocenterwigner = (2*N+1)*N+N;
    double pm;
    int column, K_min;
    mxComplexDouble *ghat2;
    std::complex<T> *iter_fhat;
    T *wigk, *wigl;
    
  // define pointer that saves the position of fhat_1^(0)
    iter_fhat = fhat+2;

  // Do recursion for 1 < n <= N and use symmetry:
    for (n=2; n<=N; n++)
    {
      // Calculate Wigner-d matrix
      wigner_d_recursion_at_pi_half<T>(N,n,wigd_min2,wigd_min1,wigd);
      
      // jump to the center of Wigner-d matrix
      wigd +=  shift_tocenterwigner;

      
      // Compute fhat by adding fhat(n,-k) = sum_{j=-n}^n ghat(k,j) * d^n(j,k) * d^n(j,0)
      // Use symmetry properties in Wigner-d functions:
      // fhat(n,k) = ghat(k,0)*d^n(k,0)*d^n(0,0)  +  sum_{j=1}^n (ghat(k,j)+(-1)^(k)*ghat(k,-j)) * d^n(k,-j)*d^n(0,-j)
      // ignore some values if - SO3FunHarmonic is real valued
      //                       - SO3FunHarmonic is antipodal
      //                       - we have right and left symmetry

      // move pointer to fhat_n^(0,0) and ghat(0,0)
      iter_fhat += 2*n;

      // If isReal: adjust bound loops for isReal and set symmetric values later 
      if(isReal)
        K_min = 0;
      else
        K_min = -n;
      
      // If antipodal: only compute spherical harmonic coefficients of even degree
      if((isAntipodal==0) || (n%2==0)){

      #pragma omp parallel for firstprivate(ghat,fhat,wigd) private(pm,wigk,wigl,ghat2,column,value)        // Parallelization
  
        // // shift pointer ghat to (K_min,0,l)
        // ghat = center_ghat + K_min + l*matrix_size;
        // // shift pointer fhat to fhat_n^(K_min,l)
        // fhat = iter_fhat + K_min + l*(2*n+1);        

        for (k= K_min; k<=n; k++)
        {
          // move pointer to fhat(n,k)
          fhat = iter_fhat - k;
          // move pointer to ghat(k,0)
          ghat = center_ghat + k;
          if(k%2==0) 
            pm = 1.0;
          else
            pm = -1.0;
          // iteration for j = 0
          wigk = wigd+k;
          wigl = wigd;
          value = (*wigk) * (*wigl);
          // (*fhat).real = (*ghat).real * value;
          // (*fhat).imag = (*ghat).imag * value;
          fhat[0] = std::complex<T>(ghat[0].real, ghat[0].imag) * value;
          ghat2 = ghat-row_len;
          ghat += row_len;
          // iteration for 0 < j <= n
          for (j= 1; j<=n; j++)
          {
            column = -j*row_len;
            value = wigk[column] * wigl[column];
            // (*fhat).real += ((*ghat).real + pm*(*ghat2).real) * value;
            // (*fhat).imag += ((*ghat).imag + pm*(*ghat2).imag) * value;
            fhat[0] += std::complex<T>(ghat[0].real + pm*ghat2[0].real, ghat[0].imag+ pm*ghat2[0].imag) * value;
            ghat2 -= row_len;
            ghat += row_len;
          }
        }
      
      }

      // permute the pointers (wigd, wigdmin1 and wigdmin2) for the next
      // recursions step for the calculation of the Wigner-d matrices.
      // Therefore the two most recently computed Wigner-d matrices are
      // used for next recursion step.
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
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // input coefficient 3-tensor
    mxDouble input_flags = 0;
    mxDouble *sym_axis;
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

    // if exists and the flag implies we want to use right and left 
    // symmetries to speed up --> get sym_axis of input
    double s[2] = {1,1};
    if( (nrhs>=4) && (flags[4]) )
      sym_axis = mxGetDoubles(prhs[3]);
    else
      sym_axis = s;

    
    const int isReal = flags[2];
    const int isAntipodal = flags[3];


  // create output data
    const int deg2dim = (bandwidth+1)*(bandwidth+1);
    plhs[0] = mxCreateNumericMatrix(deg2dim, 1, mxDOUBLE_CLASS, mxCOMPLEX);

    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);


  // call the computational routine
    if (bandwidth > 1023){
      std::vector<std::complex<long double>> ghat_tmp(deg2dim);
      // TODO: evt. muss outFourierCOeff erst im long double gerechnet werden und später auf double transformiert und dann zurückgegeben werden.
      calculate_ghat_adjoint<long double>(bandwidth,inCoeff,isReal,isAntipodal,sym_axis,ghat_tmp.data());
      for (size_t i = 0; i < deg2dim; ++i) {
        outFourierCoeff[i].real = static_cast<double>(ghat_tmp[i].real());
        outFourierCoeff[i].imag = static_cast<double>(ghat_tmp[i].imag());
      }
      // mexWarnMsgIdAndTxt("sphericalHarmonicTrafoAdjointmex:precisionLoss","Precision loss: using long double format since N > 1023.");
    }
    else{
      std::vector<std::complex<double>> ghat_tmp(deg2dim);
      calculate_ghat_adjoint<double>(bandwidth,inCoeff,isReal,isAntipodal,sym_axis,ghat_tmp.data());
      for (size_t i = 0; i < deg2dim; ++i) {
        outFourierCoeff[i].real = ghat_tmp[i].real();
        outFourierCoeff[i].imag = ghat_tmp[i].imag();
      }
    }

  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0])
    L2_normalized_sphericalHarmonics(bandwidth,outFourierCoeff);

  // free the storage
  mxDestroyArray(zeiger);

}
