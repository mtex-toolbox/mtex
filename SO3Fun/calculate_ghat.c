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
// second Euler angle beta = pi/2. Due to symmetry only the rows and
// columns with indices -L...0 are needed.
// Moreover the Wigner-d matrix with beta = pi/2 is symmetric. Hence we 
// only calculate the lower triangular part.
//
// Idea: We construct the current Wigner-d matrix by three term recurrsion.
// (refer Antje Vollrath - A Fast Fourier Algorithm on the Rotation Group, section 2.3) [*1*]
// Therefore we can not produce the first column. Since beta = pi/2 we get 
// this exterior frame very easily by representation of Wigner-d matrix 
// with Jacobi Polynomials.
// (refer Varshalovich - Quantum Theory of Angular Momentum - 1988, section 4.3.4)      [*2*]

 static void wigner_d(int N,int L,mxDouble *d_min2,mxDouble *d_min1,mxDouble *d)
{
   int col;    // column index
   int row;    // row index
   // use symmetry and run only over lower triangular matrix.
   
   // only use central (L+1)x(L+1) for current Wigner-d matrix as part 
   // of full (2*N+1)x(2*N+1) matrix. Hence we shift the pointers.
   int shift = (N+2)*(N-L);
   d += shift; d_min1 += shift; d_min2 += shift;
   
   // Define a pointer for upper triangular matrix
   mxDouble *upright;
   upright = d;
   // This pointer runs over column indices. Updating is done by shifting
   const int column_shift = N+1;
   
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

   // update all pointers
   d ++; d_min1 ++; d_min2 ++; upright += column_shift;
   // define running index
   int iter=1;
   for (row=-L+1; row<=0; row++)
   {
     sqrt_binom = sqrt_binom * sqrt((constant1-iter)/iter);
     
     value = sqrt_binom*multi;
     
     // set value in lower triangular matrix
     *d = value;
     
     // Use symmetry and set value in upper triangular matrix
     if (iter % 2 == 0)
     {
       *upright = value;
     }
     else
     {
       *upright = -value;
     }
     
     // increase running index
     iter++;
     
     // Update pointers to next value
     d ++; d_min1 ++; d_min2 ++; upright += column_shift;
    }
   // shift to next column of current inner Wigner-d matrix and one down to
   // diagonal element (-L+1,-L+1) of current Wigner-d matrix
   shift = N-L+1;
   d += shift; d_min1 += shift; d_min2 += shift;  upright = d;
   
   const int constant2 = L*L;
   const int constant3 = L-1;
   const int constant4 = constant3*constant3;
   const double constant5 = -(2.0*L-1);
   const double constant6 = -1.0*L;
   int constant7, constant8;
   long long int constant9, constant10;
   
   // now do three term recursion to receive inner part
   // (only use lower triangular matrix in loop)
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
       value = v*(*d_min1) + w*(*d_min2);
       
       // Set this value at every symmetric point where it occurs (2 times).
       // Pay attention to different signs.
       // set value in lower triangular matrix
       *d = value;
     
       // set value in upper triangular matrix
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
              
       // Update pointers for next iteration in same column
       d ++; d_min1 ++; d_min2 ++; upright += column_shift;
     }
     // Update pointers for next iteration in next column
     shift ++;
     d += shift; d_min1 += shift; d_min2 += shift; upright = d;
   }

}
 
 
 

// The computational routine
static void calculate_ghat( mxComplexDouble *fhat, mxDouble bandwidth, 
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
    mxArray *D_min2 = mxCreateDoubleMatrix(N+1,N+1,mxREAL);
    mxDouble *wigd_min2 = mxGetDoubles(D_min2);
    mxDouble *start_wigd_min2;
    start_wigd_min2 = wigd_min2;
    
    mxArray *D_min1 = mxCreateDoubleMatrix(N+1,N+1,mxREAL);
    mxDouble *wigd_min1 = mxGetDoubles(D_min1);
    mxDouble *start_wigd_min1;
    start_wigd_min1 = wigd_min1;
    
    mxArray *D = mxCreateDoubleMatrix(N+1,N+1,mxREAL);
    mxDouble *wigd = mxGetDoubles(D);
    mxDouble *start_wigd;
    start_wigd = wigd;
    
    
    // set start values for recurrence relations to compute Wigner-d matrices
    // Wigner_d(0,pi/2)
    shift = (N+2)*N;
    wigd_min2 += shift;       // go to last element of matrix
    *wigd_min2 = 1;
    wigd_min2 = start_wigd_min2;  // go back to matrix start
    
    // Wigner_d(1,pi/2)
    shift = (N+2)*(N-1);
    wigd_min1 += shift;    // go 1 left up from the last element of the matrix
    const double wert = sqrt(0.5);
    const double wigd_harmonicdegree1[3][3] = {  // values of Wigner_d(1,pi/2)
      {0.5, -wert,-0.5},
      {wert,0,wert},
      {-0.5,-wert,0.5}
    };
    shift = N-1;
    for (k=0; k<2; k++)             // fill with values
    {
      for (l=0; l<2; l++)
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
  // Use symmetry properties of Wigner-d and calculate only ghat for
  // all indices j,k,l between -N...0.
    // Create pointers for help. One saves the starting position of ghat
    // and the other saves starting position of fhat in current iteration 
    // of harmonic degree n.
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
          // next line
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
    
    

    const int constant1 = N+1;
    const int constant2 = 2*N;
    const int constant3 = 2*N+1;
    const int constant4 = 2*N+2;
    const int constant5 = 2*N+3;    
    const int constant6 = 3*N+2;
    const int constant7 = 3*N+3;
    const int constant8 = (2*N)*(2*N+1);    
    const int constant9 = (2*N)*(2*N+2);
    const int constant10 = (2*N+1)*(2*N+2);    
    const int constant11 = 2*(N+1)*(N+1); 
    const int constant12 = 4*(N+1)*(N+1);
    const int constant13 = 6*(N+1)*(N+1);        
    const int constant14 = (2*N+2)*(2*N+3);    
    const int constant15 = (2*N+2)*(3*N+3);
    const int constant16 = 4*N*N+10*N+7;          // (4*(N+1)*(N+1)+2*(N+1)+1)
    const int constant17 = 2*N*(2*N+2)*(2*N+2);
    int constant18, constant19, constant20, constant21, constant22, 
            constant23, constant24, constant25, constant26;
    int shift_2 = N*N+N-1;
    
    // Do recursion for 1 < n < N:
    
    // symmetry pointers (north-east , south-west , south-east)
    mxComplexDouble *fhat_ne_front;
    mxComplexDouble *ghat_ne_front;
    mxComplexDouble *fhat_sw_front;
    mxComplexDouble *ghat_sw_front;
    mxComplexDouble *fhat_se_front;
    mxComplexDouble *ghat_se_front;
    
    for (n=2; n<N; n++)
    {
      // Calculate Wigner-d matrix
      wigner_d(N,n,wigd_min2,wigd_min1,wigd);
      
      // Shift to inner part of Wigner-d matrix, which is not 0.
      shift_2 -= constant1;
      wigd += shift_2;
      
      // shift pointer ghat to ghat(-n,-n,-n)
      ghat += constant16*(N-n);
      
      // Set pointer of fhat and helping pointer for iterations
      iter_fhat = fhat;
      
      // Define some useful constants
      constant18 = 2*n;                       // 2*n
      constant19 = constant18 + 1;            // 2*n+1
      constant20 = constant18 * constant19;   // 2*n*(2*n+1)
      constant21 = constant4 * n;             // n*(2*N+2)
      constant22 = constant3-n;               // 2*N+1-n
      constant23 = constant5+n;               // 2*N+3 +n
      constant24 = 3*n+2;
      constant25 = constant10-constant21;     // (2*N+1)*(2*N+2) - n*(2*N+2)
      constant26 = constant14+constant21;     // (2*N+2)*(2*N+3) + n*(2*N+2)
      
      ghat_ne_front = ghat + constant18*constant4;
      fhat_ne_front = fhat + constant20;
      
      // Compute ghat by adding over all summands of current harmonic degree n
      // Compute only ghat for j<=0.
      for (j=-n; j<=0; j++){
        for (k=-n; k<=0; k++){
          // set pointers for symmetric values for j<=0
          ghat_sw_front = ghat + constant18;
          fhat_sw_front = fhat + constant18;
          ghat_se_front = ghat_ne_front + constant18;
          fhat_se_front = fhat_ne_front + constant18;       
          for (l=-n; l<=0; l++){
            // fill with values
            value = wigd[k]*wigd[l];
            
            // left up value
            ghat[0].real += fhat[0].real*value;
            ghat[0].imag += fhat[0].imag*value;
            

            // fill symmetric values:
            // left down value
            if (l!=0)
            {
              if ((l+j+n) % 2 == 0)
              {
                ghat_sw_front[0].real += fhat_sw_front[0].real*value;
                ghat_sw_front[0].imag += fhat_sw_front[0].imag*value;
              }
              else
              {   
                ghat_sw_front[0].real += -fhat_sw_front[0].real*value;
                ghat_sw_front[0].imag += -fhat_sw_front[0].imag*value;
               }
            }
            
            if (k!=0)
            {
              // right up value
              if ((k+j+n) % 2 == 0)
              {
                ghat_ne_front[0].real += fhat_ne_front[0].real*value;
                ghat_ne_front[0].imag += fhat_ne_front[0].imag*value;
              }
              else
              {
                ghat_ne_front[0].real += -fhat_ne_front[0].real*value;
                ghat_ne_front[0].imag += -fhat_ne_front[0].imag*value;
              }
              
              // right down value
              if (l!=0)
              {
                if ((k+l) % 2 == 0)
                {
                  ghat_se_front[0].real += fhat_se_front[0].real*value;
                  ghat_se_front[0].imag += fhat_se_front[0].imag*value;
                }
                else
                {
                  ghat_se_front[0].real += -fhat_se_front[0].real*value;
                  ghat_se_front[0].imag += -fhat_se_front[0].imag*value;
                }
              }
            }   
            
            // go to next row
            ghat ++; ghat_sw_front --;
            fhat ++; fhat_sw_front --;
            ghat_ne_front ++; ghat_se_front --;
            fhat_ne_front ++; fhat_se_front --;
            
          }
          // go to next column
          ghat += constant22; fhat += n;
          ghat_ne_front -= constant23; fhat_ne_front -= constant24;
        }
        // go to next matrix (3rd dimension)
        ghat += constant25;
        ghat_ne_front += constant26;
        // reset pointer fhat
        fhat = iter_fhat;
        fhat_ne_front = iter_fhat + constant20;
        // use next column of Wigner-d matrix
        wigd += constant1;
      }
      
      
      // reset pointer ghat to ghat(-N,-N,-N)
      ghat = start_ghat;
      // Set fhat to next harmonic degree
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
    
    // do step for n=N and set symmetric values for j>0 by copying from j<0
      // Define Pointers for symmetric values
      mxComplexDouble *ghat_ende;
      mxComplexDouble *ghat_sw_ende;
      mxComplexDouble *ghat_ne_ende;
      mxComplexDouble *ghat_se_ende;
      
      ghat_ende = ghat + constant17;
      ghat_ne_ende = ghat_ende + constant9;
      
      // boolean plusminus variable
      bool pm = true;
      
      // Calculate Wigner-d matrix
      wigner_d(N,N,wigd_min2,wigd_min1,wigd);
      
      // Shift to inner part of Wigner-d matrix, which is not 0.
      wigd += N;
      
      // Set pointer of fhat and helping pointer for iterations
      iter_fhat = fhat;
      
      ghat_ne_front = ghat + constant9;
      fhat_ne_front = fhat + constant8;
      
      // Compute ghat by adding over all summands of current harmonic degree N
      for (j=-N; j<=0; j++){
        for (k=-N; k<=0; k++){
          ghat_sw_front = ghat + constant2;
          fhat_sw_front = fhat + constant2;
          ghat_se_front = ghat_ne_front + constant2;
          fhat_se_front = fhat_ne_front + constant2;
          
          ghat_sw_ende = ghat_ende + constant2;
          ghat_se_ende = ghat_ne_ende + constant2;
          for (l=-N; l<=0; l++){
            // fill with values
            value = wigd[k]*wigd[l];
            
            ghat[0].real += fhat[0].real*value;
            ghat[0].imag += fhat[0].imag*value;
            

            // fill symmetric values
            // fill values for j<=0.
            if (l!=0)
            {
              if ((l+j+N) % 2 == 0)
              {
                ghat_sw_front[0].real += fhat_sw_front[0].real*value;
                ghat_sw_front[0].imag += fhat_sw_front[0].imag*value;
              }
              else
              {   
                ghat_sw_front[0].real += -fhat_sw_front[0].real*value;
                ghat_sw_front[0].imag += -fhat_sw_front[0].imag*value;
               }
            }
            
            if (k!=0)
            {
              if ((k+j+N) % 2 == 0)
              {
                ghat_ne_front[0].real += fhat_ne_front[0].real*value;
                ghat_ne_front[0].imag += fhat_ne_front[0].imag*value;
              }
              else
              {
                ghat_ne_front[0].real += -fhat_ne_front[0].real*value;
                ghat_ne_front[0].imag += -fhat_ne_front[0].imag*value;
              }
              
              if (l!=0)
              {
                if ((k+l) % 2 == 0)
                {
                  ghat_se_front[0].real += fhat_se_front[0].real*value;
                  ghat_se_front[0].imag += fhat_se_front[0].imag*value;
                }
                else
                {
                  ghat_se_front[0].real += -fhat_se_front[0].real*value;
                  ghat_se_front[0].imag += -fhat_se_front[0].imag*value;
                }
              }
            }
            
            // fill values for j>0. by symmetry property
            if (j!=0)
            {
              if (pm)
              {
                *ghat_ende = *ghat;
                
                if (l!=0)
                {
                  *ghat_sw_ende = *ghat_sw_front;
                }
                
                if (k!=0)
                {
                  *ghat_ne_ende = *ghat_ne_front;
                }
                
                if ((k*l)!=0)
                {
                  *ghat_se_ende = *ghat_se_front;
                }
                
                pm = false;
              }
              else{
                ghat_ende[0].real = -ghat[0].real;
                ghat_ende[0].imag = -ghat[0].imag;
                
                if (l!=0)
                {
                  ghat_sw_ende[0].real = -ghat_sw_front[0].real;
                  ghat_sw_ende[0].imag = -ghat_sw_front[0].imag;
                }
                
                if (k!=0)
                {
                  ghat_ne_ende[0].real = -ghat_ne_front[0].real;
                  ghat_ne_ende[0].imag = -ghat_ne_front[0].imag;
                }
                
                if ((k*l)!=0)
                {
                  ghat_se_ende[0].real = -ghat_se_front[0].real;
                  ghat_se_ende[0].imag = -ghat_se_front[0].imag;
                }
               
                pm = true;
              }
            }
            
            
            
            // next row
            ghat ++; ghat_sw_front --; 
            ghat_ende ++; ghat_sw_ende --;
            fhat ++; fhat_sw_front --;
            
            ghat_ne_front ++; ghat_se_front --;
            ghat_ne_ende ++; ghat_se_ende --;
            fhat_ne_front ++; fhat_se_front --;
            
          }
          // next column
          ghat += constant1; fhat += N;
          ghat_ne_front -= constant7; fhat_ne_front -= constant6;
          
          ghat_ende += constant1; 
          ghat_ne_ende -= constant7;
          if (N % 2 ==1)
          {
            pm = !pm;
          }
        }
        // next matrix (3rd dimension)
        ghat += constant11;
        ghat_ne_front += constant15;
        ghat_ende -= constant13;
        ghat_ne_ende -= constant11;
        // reset pointer fhat
        fhat = iter_fhat;
        fhat_ne_front = iter_fhat + constant8;
        // use next column of Wigner-d matrix
        wigd += constant1;
        
        // set plusminus true because in next matrix upright is plus;
        pm = true;
      }
    
    
// // plot routine for last created Wigner-d matrix
//     wigd = start_wigd;
//     ghat = start_ghat;
//     int matrix = (2*N+2)*(2*N+2); // size
//     ghat -= matrix;               // reset pointer start
//     
//     int helpplotzaehler = 0;
//     //mwSize k;
//     for (k=0; k<((N+1)*(N+1)); k++)
//     {
//       helpplotzaehler++;
//       ghat[0].real = *wigd;
//       ghat += 1;
//       wigd++;
//       if (helpplotzaehler % (N+1)  == 0)
//       {
//         ghat += N+1;
//         helpplotzaehler = 0;
//       }
//     }

    

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
    calculate_ghat(inCoeff,bandwidth,outFourierCoeff,(mwSize)nrows);

}