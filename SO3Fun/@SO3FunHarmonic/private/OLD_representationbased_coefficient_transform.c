/*=========================================================================
 * representationbased_coefficient_transform_old.c - eval of SO3FunHarmonic
 * 
 * The inputs are the fourier coefficients (fhat)
 * of harmonic representation of a SO(3) function and the bandwidth (N).
 * This harmonic representation will be transformed to a FFT(3) in terms
 * of Euler angles.
 * We calculate as output the coresponding fourier coefficient matrix.
 * There are two options choosable.
 * 1) It is possible to calculate ghat with even size in any dimension by
 * adding zeros in front. That is necessary since nfft is done for indices
 * -N-1 : N but the values are given for indices -N:N.
 * 2) If f is a real valued function, then ghat has one important symmetry
 * property. Hence it is sufficient to calculate ghat for indices
 * (-N:N)x(-N:N)x(0:N). Therefore ghat(:,:,0) has to be halved.
 * 
 * For the calculation of ghat we need Wigner-d matrices with Euler angle
 * beta = pi/2. There are a lot of symmetry properties in this Wigner-d
 * matrices. We use this to compute the Wigner-d's.
 * From the symmetry property of Wigner-d we also get
 *                ghat(l,j,k) = (-1)^(k+l) ghat(l,-j,k).
 * We use this by calculating only half of ghat and inserting the remaining
 * values at the end.
 * 
 * The calling syntax is:
 * 
 *		ghat = representationbased_coefficient_transform(N,fhat)
 *    ghat = representationbased_coefficient_transform(N,fhat,2^0+2^1)
 * 
 * flags:  2^0 -> fhat are the fourier coefficients of a real valued function
 *         2^1 -> make size of result even
 *         2^2 -> use L_2-normalized Wigner-D functions
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
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include "wigner_d_recursion_at_pi_half.c"   // use three term recurrence relation to compute Wigner-d matrices
#include "L2_normalized_WignerD_functions.c"  // use L_2-normalized Wigner-D functions by scaling the fourier coefficients



// The computational routine
static void calculate_ghat( const mxDouble bandwidth, mxComplexDouble *fhat,
                            const int rowcol_shift, const int fullsized,
                            mxComplexDouble *ghat, const mwSize nrows )
{

  // define usefull variables
    int k,l,j,n;                                      // running indices
    const int N = bandwidth;                          // integer bandwidth
    const int rowcol_len = (2*N+1+rowcol_shift);      // length of a row and a column
    const int matrix_size = rowcol_len*rowcol_len;    // size of one matrix
    const bool half = (fullsized==0);
    
    
  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      ghat[0].real = fhat[0].real/(2-fullsized);
      ghat[0].imag = fhat[0].imag/(2-fullsized);
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
    mxArray *D_min2 = mxCreateDoubleMatrix(2*N+1,N+1,mxREAL);
    mxDouble *wigd_min2 = mxGetDoubles(D_min2);
    mxDouble *start_wigd_min2;
    start_wigd_min2 = wigd_min2;
    
    mxArray *D_min1 = mxCreateDoubleMatrix(2*N+1,N+1,mxREAL);
    mxDouble *wigd_min1 = mxGetDoubles(D_min1);
    mxDouble *start_wigd_min1;
    start_wigd_min1 = wigd_min1;
    
    mxArray *D = mxCreateDoubleMatrix(2*N+1,N+1,mxREAL);
    mxDouble *wigd = mxGetDoubles(D);
    mxDouble *start_wigd;
    start_wigd = wigd;
    
    
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
      for (l=-1; l<=1; l++)
      {
        wigd_min1[l] = wigd_harmonicdegree1[l+1][k];  // fill with values
      }
      wigd_min1 += 2*N+1;                             // go to next column
    }
    wigd_min1 = start_wigd_min1;                      // reset pointer to matrix start
    
  // Compute ghat by iterating over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for
  // the remaining indices n > 1, except the last one. Do the last iteration 
  // n=N seperately and use symmetry in 3rd dimension of ghat here.
    // Create pointers for help. One saves the starting position of ghat
    // and the other one saves the starting position of fhat in current
    // iteration of harmonic degree n.
    mxComplexDouble *start_ghat;
    start_ghat = ghat;
    mxComplexDouble *iter_fhat;
    
  // Do recursion for n = 0.
    // Write first value of fhat in to ghat(0,0,0) , since Wigner_d(0,pi/2)=1.
    ghat[fullsized*matrix_size*N + rowcol_len*N + N] = *fhat;
    // Set pointer fhat to next harmonic degree (to the 2nd value of fhat)
    fhat ++;
    
  // Do recursion for n = 1.
    // jump to ghat(-1,-1,-1)
    ghat += fullsized*matrix_size*(N-1) + rowcol_len*(N-1) + (N-1);
    // if ghat is halfsized skip 3 values of fhat
    fhat += (!fullsized)*3;
    iter_fhat = fhat;
    // fill ghat with values := fhat(1,k,l) * d^1(j,k) * d^1(j,l)
    double value;
    for (j= -1; j<= 1; j++)
    {
      for (l= -fullsized; l<=1; l++)
      {
        for (k= -1; k<=1; k++)
        {
          value = wigd_harmonicdegree1[k+1][-j+1] * wigd_harmonicdegree1[l+1][-j+1];
          ghat[k+1].real += fhat[k+1].real* value;
          ghat[k+1].imag += fhat[k+1].imag* value;
        }
        // jump to next matrix (3rd dimension)
        ghat += matrix_size;
        fhat += 3;
      }
      // jump to next column
      ghat += -matrix_size*(2+fullsized)+rowcol_len;
      // reset pointer fhat
      fhat = iter_fhat;
    }
    // Set pointer fhat to next harmonic degree (to the 11th value of fhat)
    fhat += 6 + 3*fullsized;
    // reset pointer ghat to ghat(-N,-N,-N)
    ghat = start_ghat;
    
    
    // Be shure N>1, otherwise STOP.
    if (N==1)
    {
      if(half) // propably we have to half the values ghat(:,:,0)
      {
        for (j=0; j<3; j++)
        {
          for (k=0; k<3; k++)
          {
            ghat[k].real = ghat[k].real/2;
            ghat[k].imag = ghat[k].imag/2;
          }
          // jump to next column
          ghat += rowcol_len;
        }
      }
      
      return;
    }
    
    
  // define some usefull variables, that are used to shift pointers
    const int constant1 = 2*N+1;
    const int constant2 =  matrix_size-(2*N+1);
    const int constant3 = -matrix_size*(N+1+fullsized*N);
    const int constant4 = fullsized*matrix_size + rowcol_len + 1;
    const int shift_tocenterwigner = (2*N+1)*N+N;
    int constant5, constant6;
    bool jisnot0;
    bool rowis0_and_halfsized;

  // Do recursion for 1 < n < N:
    for (n=2; n<N; n++)
    {

      constant5 = matrix_size-(2*n+1);
      constant6 = -matrix_size*(fullsized*n+n+1)+rowcol_len;

      // Calculate Wigner-d matrix
      wigner_d_recursion_at_pi_half(N,n,wigd_min2,wigd_min1,wigd);
      
      // jump to the center of Wigner-d matrix
      wigd +=  shift_tocenterwigner;
      
      // shift pointer ghat to ghat(-n,0,-n) when fullsized and ghat(-n,0,0) otherwise
      ghat += constant4*(N-n)+rowcol_len*n;
      
      // Set pointer of fhat and helping pointer for iterations
      fhat += (2*n+1)*n*(!fullsized);
      iter_fhat = fhat;
      
      
      // Compute ghat by adding over all summands of current harmonic degree n
      // Compute ghat only for j<=0 (ghat is symmetric for j>0, more on later)
      for (j=0; j<=n; j++)
      {
        for (k= -fullsized*n; k<=n; k++)
        {
          for (l= -n; l<=n; l++)
          {
            // compute value
            value = wigd[k]*wigd[l];
            
            // set value
            ghat[0].real += fhat[0].real*value;
            ghat[0].imag += fhat[0].imag*value;
            
            // jump to next row
            ghat ++;
            fhat ++;
          }
          // jump to next matrix (3rd dimension)
          ghat += constant5;
        }
        // jump to next column
        ghat += constant6;
        // reset pointer fhat
        fhat = iter_fhat;
        // use next column of Wigner-d matrix
        wigd -= constant1;
      }
      
      // reset pointer ghat to ghat(-N,-N,-N) when fullsized and ghat(-N,-N,0) otherwise
      ghat = start_ghat;
      // Set pointer fhat to first value in next harmonic degree
      fhat += (2*n+1)*(fullsized*n+n+1);
      
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
    
    
  // Do step for n=N and set symmetric values for j>0 by copying from j<0
    // define pointer for j>0 which belongs to the symmetric values of
    // the previous pointer.
    mxComplexDouble *ghat_back;

    // boolean plusminus variable for j>0, because ghat(:,j,:) = ghat(:,-j,:)
    // except for the sign.
    // start_pm is the up right start sign (only not true if matrix starts
    // in column with index 0 and bandwidth is an odd value)
    bool start_pm = true;
    if( ((N % 2) == 1) && (half) )
      start_pm = false;
    bool pm = start_pm;
     
    // Calculate Wigner-d matrix
    wigner_d_recursion_at_pi_half(N,N,wigd_min2,wigd_min1,wigd);
    
    // jump to middle of the center of the Wigner-d matrix.
    wigd +=  shift_tocenterwigner;
  
    // shift pointer ghat to ghat(-N,0,-N) when fullsized and ghat(-N,0,0) otherwise
    ghat += rowcol_len*N; ghat_back = ghat;

    // Set pointer fhat to first value and set helping pointer for iterations
    fhat += (!fullsized)*(2*N+1)*N;
    iter_fhat = fhat;
    
    // Compute ghat by adding over all summands of current harmonic degree N
    for (j=0; j<=N; j++)
    {
      jisnot0 = (j!=0);
      for (k= -N*fullsized; k<=N; k++)
      {
        rowis0_and_halfsized = ((k==0) && half);
        for (l= -N; l<=N; l++)
        {
          // compute values
          value = wigd[k]*wigd[l];
          
          // Set value for j>=0
          ghat[0].real += fhat[0].real*value;
          ghat[0].imag += fhat[0].imag*value;
          
          // half the values of ghat(:,0,:) if not fullsized
            if(rowis0_and_halfsized)
            {
              ghat[0].real = ghat[0].real/2;
              ghat[0].imag = ghat[0].imag/2;
            }
            
          // Fill values for j<0 by symmetry property
            if(jisnot0)
            {
              if(pm)
              {
                *ghat_back = *ghat;
                // Change value of pm for next iteration
                pm = false;
              }
              else
              {
                ghat_back[0].real = -ghat[0].real;
                ghat_back[0].imag = -ghat[0].imag;
                // Change value of pm for next iteration
                pm = true;
              }
            }
          
          // jump to next row
          ghat ++; ghat_back ++;
          fhat ++;
        }
        // jump to next matrix (3rd dimension)
        ghat += constant2; ghat_back += constant2; 
      }
      // jump to next column
      ghat += constant3+rowcol_len;
      ghat_back += constant3-rowcol_len;
      
      // reset pointer fhat
      fhat = iter_fhat;
      
      // use next column of Wigner-d matrix
      wigd -= constant1;
      
      // reset plusminus to start plusminus value, because in next matrix
      // up right sign is same as before
      pm = start_pm;
    }

    // free the storage of the Wigner-d matrices
    mxDestroyArray(D);
    mxDestroyArray(D_min1);
    mxDestroyArray(D_min2);

}




// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  
  // variable declarations
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // nrows x 1 input coefficient vector
    size_t nrows;                     // size of inCoeff
    mxDouble input_flags = 0;
    mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix
    
    
  // check data types
    // check for 2 or 3 input arguments (inCoeff & bandwith)
    if( (nrhs!=2) && (nrhs!=3))
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:invalidNumInputs","Two or three inputs required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:maxlhs","One output required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:notDouble","Second input argument coefficient vector must be type double.");
    // check that number of columns in second input argument (inCoeff) is 1
    if(mxGetN(prhs[1])!=1)
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:inputNotVector","Second input argument coefficient vector must be a row vector.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs==3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "representationbased_coefficient_transform:notDouble","Third input argument flags must be a scalar double.");

    
  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:notInt","First input argument must be a natural number.");
    
    // make input matrix complex
    mxArray *zeiger = mxDuplicateArray(prhs[1]);
    if(mxMakeArrayComplex(zeiger)) {}
    
    // create a pointer to the data in the input vector (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);
    
    // get dimensions of the input vector
    nrows = mxGetM(prhs[1]);
    
    // if exists, get flags of input
    if(nrhs==3)
      input_flags = mxGetScalar(prhs[2]);
    
    bool flags[7];
    get_flags(input_flags,flags);


  // Get optional flags to generate output with suitable size.
    // If f is a real valued function, then half size in 3rd dimension of
    // ghat is sufficient. Sometimes it is necessary to add zeros in some
    // dimensions to get even size for nfft.
    // define some {0,1}-valued variables.
      const int rowcol_shift = flags[1];     // 1 if zero rows and columns are added to make size of ghat even. 0 otherwise
      const int bwp1 = (bandwidth+1);
      const int bwp1mod2 = bwp1%2;              
      const int matrix_shift = flags[1]*(!flags[0]+flags[0]*bwp1mod2); // 1 if zero matrix is added to make size of ghat even. 0 otherwise
      const int fullsized = !flags[0];    // 0 if ghat is halfsized in 3rd dimension. 1 otherwise
  
  // define length of the 3 dimensions of ghat
    mwSize dims[3];
    dims[0] = 2*bandwidth+1+flags[1];
    dims[1] = 2*bandwidth+1+flags[1]; 
    dims[2] = (2-flags[0])*bandwidth+1+matrix_shift;      
    const int start_shift = flags[1]*dims[0]*dims[1]*matrix_shift + flags[1]*dims[0] + flags[1];
    
    
  // create output data
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxCOMPLEX);
    
    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);
    // set pointer to skip first index
    outFourierCoeff += start_shift;
    
  
  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[2])
    L2_normalized_WignerD_functions(bandwidth,inCoeff);
  
  // call the computational routine
    calculate_ghat(bandwidth,inCoeff,rowcol_shift,fullsized,outFourierCoeff,(mwSize)nrows);

}