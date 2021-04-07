/*==========================================================
 * calculate_ghat.c - eval of SO3FunHarmonic
 *
 * The inputs are the fourier coefficients (ghat)
 * of harmonic representation of a SO(3) function and the bandwidth (N).
 * This harmonic representation will be transformed to a FFT(3) in terms
 * of Euler angles.
 * We calculate as output the coresponding fourier coefficient matrix.
 *
 * The calling syntax is:
 *
 *		ghat = calculate_ghat(fhat, N)
 *
 * This is a MEX-file for MATLAB.
 *
 *========================================================*/

#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <stdio.h> 
#include <complex.h>

// The Wigner D-matrix of order L, is a matrix with entries from -L:L in 
// both dimensions. Here it is sufficient to calculate Wigner-d with 
// second Euler angle beta = pi/2. Due to symmetry of ghat only the 
// columns -L...0 are needed.
//
// Idea: We construct the current Wigner-d matrix by three term recurrsion.
// (refer Antje Vollrath - A Fast Fourier Algorithm on the Rotation Group, section 2.3) [*1*]
// Therefore we can not produce the first and last row and column. Since 
// beta = pi/2 we get this exterior frame very easily by representation of 
// Wigner-d matrix with Jacobi Polynomials.
// (refer Varshalovich - Quantum Theory of Angular Momentum - 1988, section 4.3.4)      [*2*]
// Because of symmetry properties it is sufficient to calculate the north 
// west quarter, look:
//        (  A  | A'  )        + (the cross) represents row and column with index 0
//    d = ( ----+---- )        ' corresponds to flip(.,2)
//        (  A* | A*' )        * corresponds to flip(.,1)
// Moreover A is symmetric. Hence we only calculate the lower triangular 
// part of A including (--+) the left part of the row with column index 0.
 static void wigner_d(int N,mwSize L,mxDouble *d_min2,mxDouble *d_min1,mxDouble *d)
{
   int col;    // Spaltenindex
   int row;    // Zeilenindex
   // use symmetry and run only over lower triangular of north east quarter.
   
   // only use central (2*L+1)x(2*L+1) for current Wigner-d matrix as part 
   // of full (2*N+1)x(2*N+1) matrix. Hence we shift the pointers.
   int shift = 2*(N+1)*(N-L);
   d += shift; d_min1 += shift; d_min2 += shift;
   
   // Define a pointers for symmetric values
   mxDouble *upright;
   mxDouble *downright;
   mxDouble *downleft;
   upright = d; downleft = d+2*L; downright = downleft;
   // Two pointers run over column indices. Updating is done by shifting
   const int column_shift = 2*N+1;
   
   // variables for calculating Wigner-d
   double value,nenner,v,w;
   
   // produce column -L without recursion formula by:
   // Representation formula of wigner-d matrices with Jacobi Polynomials
   // The column -L is iteratively calculated by: (0.5)^L * sqrt_binom.
   // binom = sequence with squere roots of binomial coefficents 
   // (2*L  0), (2*L 1), ... (2*L  (L+row)).
   // For example we use L=10. We can write the sequence as squereroots of: 
   // 1
   // (10/1)
   // (10/1) * (9/2)
   // (10/1) * (9/2) * (8/3)
   // (10/1) * (9/2) * (8/3) * (7/4)
   // ...
   // Therefore we start with 1 and every new entry needs a multiplication 
   // with next factor.
   double sqrt_binom = 1;
   const double multi = pow(0.5,L);
   const double constant1 = 2.0*L+1;
   // Set first value in up right corner, because binomial coefficient (2*L 0) = 1.
   *d = multi;
   // Set symmetrically equivalent value in down left corner
   if (L % 2 == 0)
   {
     *downleft = multi;
   }
   else
   {
     *downleft = -multi;
   }
   // update all pointers
   d ++; d_min1 ++; d_min2 ++; upright += column_shift; downleft --; downright += column_shift;
   int iter=1;
   for (row=-L+1; row<=0; row++)
   {
     sqrt_binom = sqrt_binom * sqrt((constant1-iter)/iter);
     
     value = sqrt_binom*multi;
     
     // set value in lower triangular matrix of A
     *d = value;
     
     // Use symmetry and set the solution 4 times with some signs.
     // set value in upper triangular of A
     if (iter % 2 == 0)
     {
       *upright = value;
     }
     else
     {
       *upright = -value;
     }
     // set value in A* with same column index as original value
     if ((L+iter) % 2 == 0)
     {
       *downleft = value;
     }
     else
     {
       *downleft = -value;
     }
     // set value in A* with same column index as value of upper triangular
     // matrix of A
     if (L % 2 == 0)
     {
       *downright = value;
     }
     else
     {
       *downright = -value;
     }
     
     // increase running index
     iter++;
     
     // Update pointers to next value
     d ++; d_min1 ++; d_min2 ++; upright += column_shift; downleft --; downright += column_shift;
    }
   // shift to next column of current inner Wigner-d matrix and one down to
   // diagonal element (-L+1,-L+1) of current Wigner-d matrix
   shift = 2*N-L+1; 
   d += shift; d_min1 += shift; d_min2 += shift;  upright = d; downleft = d + 2*L-2; downright = downleft;
   
   
   const int constant2 = L*L;
   const int constant3 = L-1;
   const int constant4 = constant3*constant3;
   const double constant5 = -(2.0*L-1);
   const double constant6 = -1.0*L;
   int constant7, constant8;
   long long int constant9, constant10;
   
   // now do three term recursion to receive inner part
   // (only use lower triangular matrix of north west part of Wigner-d)
   for (col=-L+1; col<=0; col++)
   {
     for (row=col; row<=0; row++)
     {
       // calculate the auxiliar variables similar like in refence [*1*].
       constant7 = row*row;
       constant8 = col*col;
       constant9 = (constant2-constant7);
       constant10 = (constant2-constant8);
       nenner = sqrt(constant9*constant10) * constant3;
       v = constant5*row*col / nenner;
       constant9 = (constant4-constant7);
       constant10 = (constant4-constant8);
       w = constant6 * sqrt(constant9*constant10) / nenner;
       // get value of inner part
//        if (L==216)
//        {
//          value = nenner;
//        }
//        else
//        {    
         value = v*(*d_min1) + w*(*d_min2);
//        }
       
       // Set this value at every symmetric point where it occurs (4 times).
       // Pay attention to different signs.
       // Hence input uses 4 pointers, the calculated value and some
       // indices to determine the signs.
       // set value in lower triangular matrix of A
       *d = value;
     
       // Use symmetry and set the solution 4 times with some signs.
       // set value in upper triangular of A
       if (row != col)
       {
         if ((row+col) % 2 == 0)
         {
           *upright = value;
         }
         else
         {
            *upright = -value;
         }
       }
       // set value in A* with same column index as original value
       if (row+col != 0)
       {
         if (L % 2 == 0)
         {
           *downright = value;
         }
         else
         {
           *downright = -value;
         }
       }
       // set value in A* with same column index as value of upper triangular
       // matrix of A     
       if ((row != 0) && (row != col))
       {
         if ((L+(row+col)) % 2 == 0)
         {
           *downleft = value;
         }
         else
         {
           *downleft = -value;
         }
       }

       
       // Update pointers for next iteration in same column
       d ++; d_min1 ++; d_min2 ++; upright += column_shift; downleft --; downright += column_shift;
     }
     // Update pointers for next iteration in next column
     shift ++;
     d += shift; d_min1 += shift; d_min2 += shift; upright = d; downleft = d - 2*col-2; downright = downleft;
   }

}
 
 
 

// The computational routine
static void calculate_ghat_longwig( mxComplexDouble *fhat, mxDouble bandwidth, 
                            mxComplexDouble *ghat, mwSize nrows )
{
  // running indices
  int k,l,j,n;
  // shifting pointers
  int shift;
  // integer bandwidth
  const int N = bandwidth;

  
  // Be shure N>0. Otherwise return the trivial solution.
  if(N==0)
  {
    *ghat =*fhat;
    return;
  }
  
  // Idea: Calculate Wigner-d matrix by recursion formula from last two 
  // wigner-d matrices.
    // create 3 Wigner-d matrices for recurrence relation (2 as input and 1
    // as output). Also get an auxiliary pointer to the matrices in each case.
    mxArray *D_min2 = mxCreateDoubleMatrix(2*N+1,2*N+1,mxREAL);
    mxDouble *wigd_min2 = mxGetDoubles(D_min2);
    mxDouble *start_wigd_min2;
    start_wigd_min2 = wigd_min2;
    
    mxArray *D_min1 = mxCreateDoubleMatrix(2*N+1,2*N+1,mxREAL);
    mxDouble *wigd_min1 = mxGetDoubles(D_min1);
    mxDouble *start_wigd_min1;
    start_wigd_min1 = wigd_min1;
    
    mxArray *D = mxCreateDoubleMatrix(2*N+1,2*N+1,mxREAL);
    mxDouble *wigd = mxGetDoubles(D);
    mxDouble *start_wigd;
    start_wigd = wigd;
    
    
    // set start values for recurrence relations to compute Wigner-d matrices
    // Wigner_d(0,pi/2)
    shift = 2*(N+1)*N;
    wigd_min2 += shift;       // go to center of matrix
    *wigd_min2 = 1;
    wigd_min2 = start_wigd_min2;  // go back to matrix start
    
    // Wigner_d(1,pi/2)
    shift = 2*(N+1)*(N-1);
    wigd_min1 += shift;    // go 1 left up from the center of the matrix
    double wert = sqrt(0.5);
    double wigd_harmonicdegree1[3][3] = {           // values of Wigner_d(1,pi/2)
      {0.5, -wert,-0.5},
      {wert,0,wert},
      {-0.5,-wert,0.5}
    };
    shift = 2*(N-1);
    for (k=0; k<3; k++)             // fill with values
    {
      for (l=0; l<3; l++)
      {
        *wigd_min1 = wigd_harmonicdegree1[l][k];
        wigd_min1 ++;              // go to next line
      }
      wigd_min1 += shift;          // go to next column
    }
    wigd_min1 = start_wigd_min1;    // go back to matrix start
     
  // Compute ghat by iteration over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for 
  // the remaining n > 1.
    // Create pointers for help. They save the starting position of ghat 
    // and fhat in current iteration of harmonic degree n.
    mxComplexDouble *start_ghat;
    start_ghat = ghat;
    mxComplexDouble *iter_fhat;

    // Do recursion for n = 0.
    // Go to the center of ghat and write first value of fhat, since d^0=1.
    ghat += N*(N+1)*(N+1)*4 + 2*(N+1)*N + N;
    *ghat = *fhat;
    fhat ++;
    ghat = start_ghat;
    
    // Do recursion for n = 1.
    // Go to ghat(-1,-1,-1)
    ghat += (N-1)*(N+1)*(N+1)*4 + 2*(N+1)*(N-1) + (N-1);  
    iter_fhat = fhat;
    double value;
    for (j=0; j<3; j++){
      for (l=0; l<3; l++){
        for (k=0; k<3; k++){
          // fill with values
          value = wigd_harmonicdegree1[k][j] * wigd_harmonicdegree1[l][j];
          ghat[0].real += fhat[0].real* value;
          ghat[0].imag += fhat[0].imag* value;
          // next row
          ghat ++;
          fhat ++;
        }
        // next column
        ghat += 2*N-1;
      }
      // next matrix (3rd dimension)
      ghat += (2*N+2)*(2*N-1);
      // reset pointer fhat
      fhat = iter_fhat;
    }
    // Set pointer to next harmonic degree
    fhat += 9;
    // reset pointer ghat to ghat(-N,-N,-N)
    ghat = start_ghat;
    
    
    // Be shure N>1, otherwise STOP
    if (N==1)
    {
      return;
    }
    
    
    // Define some variables

    const int constant3 = 2*N+1;
    const int constant4 = 2*N+2;
    
    const int constant10 = (2*N+1)*(2*N+2);    
   
    const int constant14 = (2*N+2)*(4*N+3);    
   
    const int constant16 = 4*N*N+10*N+7;          // (4*(N+1)*(N+1)+2*(N+1)+1)
    const int constant17 = 2*N*(2*N+2)*(2*N+2);
    int constant18, constant19, constant21, constant22, constant23;
    int shift_2 = 2*N*N+2*N - (2*N+1);
    
    
    
    
    // Do recursion for 1 < n < N:
    for (n=2; n<N; n++)
    {
      // Calculate Wigner-d matrix
      wigner_d(N,n,wigd_min2,wigd_min1,wigd);
      
      // Shift to inner part of Wigner-d matrix, which is not 0.
      shift_2 -= constant3;
      wigd += shift_2;
      
      // shift pointer ghat to ghat(-n,-n,-n)
      ghat += constant16*(N-n);
      
      // Set pointer of fhat and helping pointer for iterations
      iter_fhat = fhat;
      
      // Define some useful constants
      constant18 = 2*n;                       // 2*n
      constant19 = constant18 + 1;            // 2*n+1
      constant21 = constant4 * constant18;    // (2*N+2)*(2*n)
      constant22 = constant3 - constant18;
      constant23 = constant10 - constant21;
              
      // Compute ghat by adding over all summands of current harmonic degree n
      for (j=-n; j<=0; j++){
        for (k=-n; k<=n; k++){
          for (l=-n; l<=n; l++){
            // fill with values
            value = wigd[k]*wigd[l];
            
            ghat[0].real += fhat[0].real*value;
            ghat[0].imag += fhat[0].imag*value;
            
            // go to next row
            ghat ++;
            fhat ++;
          }
          // go to next column
          ghat += constant22;
        }
        // go to next matrix (3rd dimension)
        ghat += constant23;
        // reset pointer fhat
        fhat = iter_fhat;
        // use next column of Wigner-d matrix
        wigd += constant3;
      }
      
      // reset pointer ghat to ghat(-N,-N,-N)
      ghat = start_ghat;
      // Set pointer to next harmonic degree
      fhat += constant19*constant19;
      
      // change pointers (wigd, wigdmin1 and wigdmin2) with regard to next
      // recursions iteration of Wigner-d matrices. Therefore the two most
      // recently computed Wigner-d matrices are used for next recursion.
      // The other matrix will be overwritten in the next step.
      // use wigd as exchange variable
      wigd = start_wigd_min2;
      
      start_wigd_min2 = start_wigd_min1;
      start_wigd_min1 = start_wigd;
      start_wigd = wigd;
      
      wigd_min1 = start_wigd_min1;
      wigd_min2 = start_wigd_min2;
    }
    
    // do step for n=N and set symmetric values
      // Get Pointer for symmetric values
      mxComplexDouble *ghat_right;
      ghat_right = ghat + constant17;
      // boolean plusminus variable
      bool pm = true;
      
      // Calculate Wigner-d matrix
      wigner_d(N,N,wigd_min2,wigd_min1,wigd);
      
      // Shift to inner part of Wigner-d matrix, which is not 0.
      wigd += N;
      
      // Set pointer of fhat and helping pointer for iterations
      iter_fhat = fhat;
      
      // Compute ghat by adding over all summands of current harmonic degree n
      for (j=-N; j<=0; j++){
        for (k=-N; k<=N; k++){
          for (l=-N; l<=N; l++){
            // fill with values
            value = wigd[k]*wigd[l];
            
            ghat[0].real += fhat[0].real*value;
            ghat[0].imag += fhat[0].imag*value;
            
            // fill symmetric values
            if (pm){
              *ghat_right = *ghat;
              pm = false;
            }
            else{
              ghat_right[0].real = -ghat[0].real;
              ghat_right[0].imag = -ghat[0].imag;
              pm = true;
            }
                          
            // next row
            ghat ++; ghat_right ++;
            fhat ++;
          }
          // next column
          ghat ++; ghat_right ++;
        }
        // next matrix (3rd dimension)
        ghat += constant4;
        ghat_right -= constant14;
        // reset pointer fhat
        fhat = iter_fhat;
        // use next column of Wigner-d matrix
        wigd += constant3;
        
        // set plusminus true because in next matrix upright is plus;
        pm = true;
      }
    
    
// plot routine for last created Wigner-d matrix
    wigd = start_wigd;
    ghat = start_ghat;
    int matrix = (2*N+2)*(2*N+2); // size
    ghat -= matrix;               // reset pointer start
    
    //mwSize k;
    for (k=-N; k<=0; k++){
      for (l=-N; l<=N; l++){
        ghat[0].real = *wigd;
        ghat += 1;
        wigd++;
      }
      ghat++;
    }
    

}


// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

  // variable declarations here
    mxComplexDouble *inCoeff;         // nrows x 1 input coefficient vector
    size_t nrows;                     // size of inCoeff
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix

  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs!=2) {
        mexErrMsgIdAndTxt("calculate_ghat:notInt","Two inputs required.");
    }
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("calculate_ghat:notInt","One output required.");
    }
    // make sure the first input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[0]) && !mxIsDouble(prhs[0]) ) {
        mexErrMsgIdAndTxt("calculate_ghat:notInt",
                "Input coefficient vector must be type double.");
    }
    // check that number of columns in first input argument (inCoeff) is 1
    if(mxGetN(prhs[0])!=1) {
        mexErrMsgIdAndTxt("calculate_ghat:notInt",
                "Input coefficient vector must be a row vector.");
    }
    // make sure the second input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[1]) ||
         mxIsComplex(prhs[1]) ||
         mxGetNumberOfElements(prhs[1])!=1) {
        mexErrMsgIdAndTxt("calculate_ghat:notInt",
                "Input bandwidth must be a Scalar double.");
    }

  // read input data
    // make input matrix complex
    mxArray *zeiger = mxDuplicateArray(prhs[0]);
    if (mxMakeArrayComplex(zeiger)) {}

    // create a pointer to the data in the input vector (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);

    // get dimensions of the input vector
    nrows = mxGetM(prhs[0]);

    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[1]);
    // check whether bandwidth is natural number
    if( (round(bandwidth)-bandwidth)!=0 ||
         bandwidth<0 ) {
        mexErrMsgIdAndTxt("calculate_ghat:notInt",
                "Input must be a natural number.");
    }

  // create output data
    mwSize dims[3] = {2*bandwidth+2, 2*bandwidth+2, 2*bandwidth+2};
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxCOMPLEX);

    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);
    // set pointer to skip first index
    outFourierCoeff += (dims[1])*(dims[1]+1)+1;

  // call the computational routine
    calculate_ghat_longwig(inCoeff,bandwidth,outFourierCoeff,(mwSize)nrows);

}