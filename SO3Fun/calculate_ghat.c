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

static void pointer_shift(mxDouble *d, mxDouble *d_min1, mxDouble *d_min2,
                mxDouble *upright, mxDouble *downleft, mxDouble *downright)
{
  
  
}

static inline void set_wigner_values(int L, int row, int col, double value,
          mxDouble *d, mxDouble *upright, mxDouble *downright, mxDouble *downleft)
{
  *d =value;
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

}


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
   
   
   mxDouble *upright;
   mxDouble *downright;
   mxDouble *downleft;
   upright = d; downleft = d+2*L; downright = downleft;
   int column_shift = 2*N+1;
   double value;
   
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
   double multi = pow(0.5,L);
   *d = multi; 
   if (L % 2 == 0)
   {
     *downleft = multi;
   }
   else
   {
     *downleft = -multi;
   }
   d ++; d_min1 ++; d_min2 ++; upright += column_shift; downleft --; downright += column_shift;
   int iter=1;
   for (row=-L+1; row<=0; row++)
   {
     sqrt_binom = sqrt_binom * sqrt((2.0*L+1-iter)/iter);
     
     value = sqrt_binom*multi;
     
     *d = value;
     
     if (iter % 2 == 0)
     {
       *upright = value;
     }
     else
     {
       *upright = -value;
     }
     
     if ((L+iter) % 2 == 0)
     {
       *downleft = value;
     }
     else
     {
       *downleft = -value;
     }
     
     if (L % 2 == 0)
     {
       *downright = value;
     }
     else
     {
       *downright = -value;
     }
     
     iter ++; 
     d ++; d_min1 ++; d_min2 ++; upright += column_shift; downleft --; downright += column_shift;
    }
   // shift to next column of current inner Wigner-d matrix and one down to
   // diagonal element (-L+1,-L+1) of current Wigner-d matrix
   shift = 2*N-L+1; 
   d += shift; d_min1 += shift; d_min2 += shift;  upright = d; downleft = d + 2*L-2; downright = downleft;
   
   
   // now do three term recursion to receive inner part
   // (only use lower triangular matrix of north west part of Wigner-d)
   double nenner,v,w;
   for (col=-L+1; col<=0; col++)
   {
     
     for (row=col; row<=0; row++)
     {
       // calculate the auxiliar variables similar like in refence [*1*].
       nenner = sqrt((L*L-row*row)*(L*L-col*col))*(L-1);
       v = -(2.0*L-1)*row*col / nenner;
       w = -1.0*L * sqrt( ((L-1)*(L-1)-row*row) * ((L-1)*(L-1)-col*col) ) / nenner;
       // get value of inner part
       value = v*(*d_min1) + w*(*d_min2) ;
       
       // Set this value at every symmetric point where it occurs (4 times).
       // Pay attention to different signs.
       // Hence input uses 4 pointers, the calculated value and some
       // indices to determine the signs.
       set_wigner_values(L,row,col,  value,  d,upright,downright,downleft);
       
       
       d ++; d_min1 ++; d_min2 ++; upright += column_shift; downleft --; downright += column_shift;
     }
     shift = 2*N+1+col;
     d += shift; d_min1 += shift; d_min2 += shift; upright = d; downleft = d - 2*col-2; downright = downleft;
   }

}

// The computational routine
static void calculate_ghat( mxComplexDouble *fhat, mxDouble N, 
                            mxComplexDouble *ghat, mwSize n )
{
  // Be shure N>0. Otherwise return the trivial solution.
  if(N==0) {
    ghat += 3;
    *ghat =*fhat;
    return;
  }


  // 1.) Calculate Wigner-d matrix by recursion formula from last two 
  // wigner-d matrices.
    // create 3 Wigner-d matrices for recurrence relation (2 as input and 1
    // as output). Also get an auxiliary pointer to the matrix in each case.
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
    
    
    // set start for recurrence relations to compute Wigner-ds
    int mid_index = 2*(N+1)*N;
    wigd_min2 += mid_index;       // go to mid of matrix
    *wigd_min2 = 1;
    wigd_min2 = start_wigd_min2;  // go back to matrix start
    
    int mid_1northwest = 2*(N+1)*(N-1);
    wigd_min1 += mid_1northwest;    // go 1 left up of the mid of matrix
    double wert = sqrt(0.5);
    double feld[3][3] = {
      {0.5, -wert,-0.5},
      {wert,0,wert},
      {-0.5,-wert,0.5}
    };
    mwSize k;
    mwSize l;
    int shift = 2*(N-1);
    for (k=0; k<3; k++)             // fill with values
    {
      for (l=0; l<3; l++)
      {
        *wigd_min1 = feld[l][k];
        wigd_min1 ++;
      }
      wigd_min1 += shift;          // go to next line one left of mid
    }
    wigd_min1 = start_wigd_min1;    // go back to matrix start
    
    mxComplexDouble *start_ghat;
    start_ghat = ghat;
    mxComplexDouble *iter_fhat;
    
    // n = 0
    ghat += N*(N+1)*(N+1)*4 + 2*(N+1)*(N+1) + N+1;
    *ghat = *fhat;
    fhat ++;
    ghat = start_ghat;
    
    // n = 1
    ghat += (N-1)*(N+1)*(N+1)*4 + 2*(N+1)*N + N;
    iter_fhat = fhat;
    for (j=-1; j<=1; j++){
      for (l=-1; l<=1; l++){
        for (k=-1; k<=1; k++){
          
          *ghat = *fhat*feld[k][l];
          ghat ++;
          fhat ++;
        }
        ghat += 2*N-1;
      }
      ghat += (2*N+2)*(2*N-1);
      fhat = iter_fhat;
    }
    
    
    // do recursion
    mwSize j;
    mwSize n;
    int maxN = N;
    
    for (n=2; n<=N; n++)
    {
      wigner_d(maxN,n,wigd_min2,wigd_min1,wigd);
      
      
      // mache rechnung fuer ghat
      for (j=-n; j<=0; j++){
        for (k=-n; k<=n; k++){
          for (l=-n; l<=n; l++){
            
          }
        }
          
      }
      
      
      
      // tausche zeiger wigd wigdmin1 und wigdmin2
      // use wigd as exchange variable
      wigd = start_wigd_min2;
      
      start_wigd_min2 = start_wigd_min1;
      start_wigd_min1 = start_wigd;
      start_wigd = wigd;
      
      wigd_min1 = start_wigd_min1;
      wigd_min2 = start_wigd_min2;
    
    }
    

    
    
// plot routine for created Wigner-d matrix
    int matrix = (2*N+1)*(2*N+1); // size
    ghat -= matrix;               // reset pointer start
    
    //mwSize k;
    for (k=0; k<matrix; k++)
    {
      
      ghat[0].real = *wigd_min1;
      ghat += 1;
      wigd_min1++;
    }
    
    
    
    // 10.) Calculate ghat
    
//     mxComplexDouble data;
//     mxComplexDouble data2 = {3,3};
//     mxComplexDouble data3 = {1,1};
//     data.real = data3.real + data2.real;
//     data.imag = data3.imag + data2.imag;
//    double complex data;
//    double complex data2 = 3 + 4.1*I;
//   double complex data3 = 1.2 + 5*I;
//ghat[1].imag = fhat[0].imag + fhat[1].imag;
    
    
     for (k=0; k<n; k++)
    {
      
      *ghat = *fhat;  // write value of pointer fhat in value of pointer ghat
      ghat += 1;      // go to next adress with pointer
      fhat++;         //
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
    outFourierCoeff += (dims[1])*(dims[1]);

  // call the computational routine
    calculate_ghat(inCoeff,bandwidth,outFourierCoeff,(mwSize)nrows);

}