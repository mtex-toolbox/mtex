/*=========================================================================
 * calculate_ghat_longwig.c - eval of SO3FunHarmonic
 * 
 * The inputs are the fourier coefficients (ghat)
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
 * (-N:N)x(0:N)x(-N:N). Therefore ghat(:,0,:) has to be halved.
 * 
 * For the calculation of ghat we need Wigner-d matrices with Euler angle
 * beta = pi/2. There are a lot of symmetry properties in this Wigner-d
 * matrices. We use this to compute the Wigner-d's.
 * From the symmetry property of Wigner-d we also get
 *                ghat(k,l,j) = (-1)^(k+l) ghat(k,l,-j).
 * We use this by calculating only half of ghat and inserting the remaining
 * values at the end.
 * 
 * The calling syntax is:
 * 
 *		ghat = calculate_ghat(N,fhat)
 *    ghat = calculate_ghat(N,fhat,'makeeven')
 *    ghat = calculate_ghat(N,fhat,'isReal')
 *    ghat = calculate_ghat(N,fhat,'makeeven','isReal')
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






/* 
 * The Wigner D-matrix of order L, is a matrix with entries from -L:L in
 * both dimensions. Here it is sufficient to calculate Wigner-d with
 * second Euler angle beta = pi/2. Due to symmetry of ghat only the
 * columns -L...0 are needed.
 * Because of symmetry properties in Wigner-d it is sufficient to calculate
 * the upper left quadrant (A in following outline) and the left part of row
 * with index 0 and the upper part of column with index 0, look:
 *        (  A  | A'  )        + (the cross) represents row and column with index 0
 *    d = ( ----+---- )        ' corresponds to flip(.,2)
 *        (  A* | A*' )        * corresponds to flip(.,1)
 * Moreover this part
 *      (         | )
 *      (    A    | )
 *      (         | )
 *      ( --------+ )
 * of the Wigner-d matrix with beta = pi/2 is symmetric. Hence we only
 * calculate the lower triangular matrix of A including (--+).
 * The Wigner-d matrix with bandwidth L has size (2*L+1)x(2*L+1). It is
 * located in the center of a (2*N+1)x(2*N+1) matrix of zeros.
 * In the current case it is sufficient to use the upper left quadrant.
 * Hence, if harmonic degree is L, only the lower right (L+1)x(L+1) part
 * of upper left (N+1)x(N+1) quadrant is needed.
 * 
 * Idea: We construct the current Wigner-d matrix by three term recurrsion.
 * (refer Antje Vollrath - A Fast Fourier Algorithm on the Rotation Group, section 2.3) [*1*]
 * Therefore we can not produce the exterior frame (first and last row and
 * column).
 * Since beta = pi/2 we get this exterior frame very easily by
 * representation of Wigner-d matrices with Jacobi Polynomials.
 * (refer Varshalovich - Quantum Theory of Angular Momentum - 1988, section 4.3.4)      [*2*]
*/ 
static void wigner_d(int N,mwSize L,mxDouble *d_min2,mxDouble *d_min1,mxDouble *d)
{

    int col;      // column index
    int row;      // row index
    double value;
    
    // shift the pointer to d(-L,-L).
    int shift = 2*(N+1)*(N-L);
    d += shift;
    
    // define pointers for symmetric values
    mxDouble *upright;
    mxDouble *downright;
    mxDouble *downleft;
    upright = d; downleft = d+2*L; downright = downleft;
    
    // Two pointers run over column indices. Updating is done by shifting
    const int column_shift = 2*N+1;
    
  // Produce the exterior frame (row L and column -L) without recursion
  // formula by:
    // Representation formula of Wigner-d matrices with Jacobi Polynomials
    // The column -L is iteratively calculated by: (0.5)^L * sqrt_binom.
    // sqrt_binom = sequence with square roots of binomial coefficents
    // (2*L  0), (2*L 1), ... (2*L  (L+row)).
    // For instance we use L=10. We can write the sequence as square roots of:
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
    
    // Set first value in up right corner, because binomial coefficient
    // (2*L 0) = 1.
    *d = multi;
    
    // Set symmetrically equivalent value in down left corner
    // (pay attention to sign)
    if (L % 2 == 0)
      *downleft = multi;
    else
      *downleft = -multi;
    
    // update the pointers
    d ++; downleft --; upright += column_shift; downright += column_shift;
    
    // define running index
    int iter=1;
    
    for (row=-L+1; row<=0; row++)
    {
      sqrt_binom = sqrt_binom * sqrt((constant1-iter)/iter);
      
      value = sqrt_binom*multi;
      
      // Set value in lower triangular matrix of A
      *d = value;
      
    // Use symmetry and set the value 4 times with some signs.
      // Set value in upper triangular matrix of A.
      if (iter % 2 == 0)
        *upright = value;
      else
        *upright = -value;
      
      // Set value in A* with same column index as original value.
      if ((L+iter) % 2 == 0)
        *downleft = value;
      else
        *downleft = -value;
      
      // Set value in A* with same column index as value of upper triangular matrix of A.
      if (L % 2 == 0)
        *downright = value;
      else
        *downright = -value;
      
      // increase running index
      iter++;
      
      // Update pointers to next value
      d ++; upright += column_shift; downleft --; downright += column_shift;
    }
    
    // shift to diagonal element (-L+1,-L+1) of current Wigner-d matrix
    shift = 2*(N+1)*(N-L+1);
    d_min1 += shift; d_min2 += shift;
    shift = 2*N-L+1;
    d += shift; upright = d; downleft = d + 2*L-2; downright = downleft;
    
  // Now do three term recursion to receive inner part of Wigner-d matrix.
    // define some variables for calculating Wigner-d by recursion formula
    double nenner,v,w;
    const int constant2 = L*L;
    const int constant3 = L-1;
    const int constant4 = constant3*constant3;
    const double constant5 = -(2.0*L-1);
    const double constant6 = -1.0*L;
    int constant7, constant8;
    long long int constant9, constant10;
    
    // only iterate over lower triangular matrix in the loop
    for (col=-L+1; col<=0; col++)
    {
      for (row=col; row<=0; row++)
      {
        // calculate the auxiliar variables v,w similar like in reference [*1*].
        constant7 = row*row;
        constant8 = col*col;
        constant9 = (constant2-constant7);
        constant10 = (constant2-constant8);
        nenner = sqrt(constant9*constant10) * constant3;
        v = constant5*row*col / nenner;
        constant9 = (constant4-constant7);
        constant10 = (constant4-constant8);
        w = constant6 * sqrt(constant9*constant10) / nenner;
        
        // get the value of inner part
        value = v*(*d_min1) + w*(*d_min2);
        
        // Set this value at every symmetric point where it occurs (4 times).
        // Pay attention to different signs.
        // 1) Set value in lower triangular matrix of A
        *d = value;
        
        // 2) Set value in upper triangular matrix of A
        if (row != col)
        {
          if ((row+col) % 2 == 0)
            *upright = value;
         else
           *upright = -value;
        }
        
        // 3) Set value in A* with same column index as original value
        if (row+col != 0)
        {
          if (L % 2 == 0)
            *downright = value;
          else
            *downright = -value;
        }
        
        // 4) Set value in A* with same column index as value of upper triangular matrix of A
        if ((row != 0) && (row != col))
        {
          if ((L+(row+col)) % 2 == 0)
            *downleft = value;
          else
            *downleft = -value;
        }
        
        // Update pointers for next iteration in same column and next row
        d ++; d_min1 ++; d_min2 ++; downleft --;
        // and in next column and same row
        upright += column_shift; downright += column_shift;
      }
      
      // Update pointers for next iteration in next column
      shift ++;
      d += shift; d_min1 += shift; d_min2 += shift; downleft = d - 2*col-2;
      // and next row
      upright = d; downright = downleft;
    }

}




// The computational routine
static void calculate_ghat_longwig( mxDouble bandwidth, mxComplexDouble *fhat,
                            int row_shift, int col_shift, int fullsized,
                            mxComplexDouble *ghat, mwSize nrows )
{

  // define usefull variables
    int k,l,j,n;                                      // running indices
    const int N = bandwidth;                          // integer bandwidth
    int shift;                                        // helps by shifting pointers
    const int row_len = (fullsized*N+N+1+col_shift);  // length of a row
    const int col_len = (2*N+1+row_shift);            // length of a column
    const int matrix_size = row_len*col_len;          // size of one matrix
    const int halfsized = 1-fullsized;
    
    
  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      ghat[0].real = fhat[0].real/(2-fullsized);
      ghat[0].imag = fhat[0].imag/(2-fullsized);
      return;
    }
    
    
  // Idea: Calculate Wigner-d matrix by recursion formula from last two
  // Wigner-d matrices.
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
    shift = 2*(N+1)*N;
    wigd_min2 += shift;           // go to last column and center row of matrix *
    *wigd_min2 = 1;
    wigd_min2 = start_wigd_min2;  // go back to matrix start
    
    // Wigner_d(1,pi/2)
    shift = 2*(N+1)*(N-1);
    wigd_min1 += shift;    // go 1 left up from *
    const double wert = sqrt(0.5);
    const double wigd_harmonicdegree1[3][3] = { // values of Wigner_d(1,pi/2)
                                                  {0.5, -wert,-0.5},
                                                  {wert,0,wert},
                                                  {-0.5,-wert,0.5}    };
    shift = 2*(N-1);
    for (k=0; k<2; k++)
    {
      for (l=0; l<3; l++)
      {
        *wigd_min1 = wigd_harmonicdegree1[l][k];  // fill with values
        wigd_min1 ++;                             // go to next row
      }
      wigd_min1 += shift;                         // go to next column
    }
    wigd_min1 = start_wigd_min1;                  // go back to matrix start
    
  // Compute ghat by iterating over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for
  // the remaining n > 1, except the last one. Do the last iteration n=N
  // seperately and use symmetry in third dimension of ghat here.
    // Create pointers for help. One saves the starting position of ghat
    // and the other one saves the starting position of fhat in current
    // iteration of harmonic degree n.
    mxComplexDouble *start_ghat;
    start_ghat = ghat;
    mxComplexDouble *iter_fhat;
    
  // Do recursion for n = 0.
    // Go to the center of ghat and write first value of fhat, since d^0=1.
    ghat += matrix_size*N + fullsized*col_len*N + N;
    *ghat = *fhat;
    fhat ++;
    ghat = start_ghat;
    
  // Do recursion for n = 1.
    // go to ghat(-1,-1,-1)
    ghat += matrix_size*(N-1) + fullsized*col_len*(N-1) + (N-1);
    // if halfsized skip 3 values of fhat
    fhat += halfsized*3;
    iter_fhat = fhat;
    // fill ghat with values := fhat(1,k,l) * d^1(k,j) * d^1(l,j)
    double value;
    for (j=0; j<3; j++)
    {
      for (l=halfsized; l<3; l++)
      {
        for (k=0; k<3; k++)
        {
          value = wigd_harmonicdegree1[k][j] * wigd_harmonicdegree1[l][j];
          ghat[0].real += fhat[0].real* value;
          ghat[0].imag += fhat[0].imag* value;
          // go to next row
          ghat ++;
          fhat ++;
        }
        // go to next column
        ghat += col_len-3;
      }
      // go to next matrix (3rd dimension)
      ghat += col_len*row_len - col_len*(2+fullsized);
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
      if(fullsized == 0)
      {
        for (j=0; j<3; j++)
        {
          for (k=0; k<3; k++)
          {
            ghat[k].real = ghat[k].real/2;
            ghat[k].imag = ghat[k].imag/2;
          }
          // go to next matrix (3rd dimension)
          ghat += col_len*row_len;
        }
      }
      
      return;
    }
    
    
  // define some usefull variables
    const bool full = (fullsized==0);
    bool test1;
    bool test2;
    const int constant1 = N*fullsized;
    const int constant2 = 2*N+1;
    const int constant3 = col_len*col_shift;
    const int constant4 = col_len*col_shift - 2*matrix_size;
    const int constant5 = 2*N*matrix_size;
    const int constant6 = matrix_size + fullsized*col_len + 1;
    int constant7, constant8, constant9, constant10, constant11, constant12, constant13;
    int shift_toinnerwigner = 2*N*N+2*N - (2*N+1);
    
  // Do recursion for 1 < n < N:
    for (n=2; n<N; n++)
    {
      // define some useful constants
      constant7 = 2*n+1;
      constant8 = col_len - constant7;
      constant9 = fullsized*n;
      constant10 = constant9 + n + 1;                 // fullsized*n + n+1
      constant11 = matrix_size - col_len*constant10;
      constant12 = constant7*constant10;
      constant13 = constant7*n*halfsized;
      
      // Calculate Wigner-d matrix
      wigner_d(N,n,wigd_min2,wigd_min1,wigd);
      
      // Shift to inner part of Wigner-d matrix, which is not 0.
      shift_toinnerwigner -= constant2;
      wigd +=  shift_toinnerwigner;
      
      // shift pointer ghat to ghat(-n,-n,-n) when fullsized. ghat(-n,0,-n) otherwise
      ghat += constant6*(N-n);
      
      // Set pointer of fhat and helping pointer for iterations
      fhat += constant13;
      iter_fhat = fhat;
      
      
      // Compute ghat by adding over all summands of current harmonic degree n
      // Compute ghat only for j<=0 (ghat is symmetric for j>0, more on later)
      for (j=-n; j<=0; j++)
      {
        for (k=-constant9; k<=n; k++)
        {
          for (l=-n; l<=n; l++)
          {
            // compute value
            value = wigd[k]*wigd[l];
            
            // set value
            ghat[0].real += fhat[0].real*value;
            ghat[0].imag += fhat[0].imag*value;
            
            // go to next row
            ghat ++;
            fhat ++;
          }
          // go to next column
          ghat += constant8;
        }
        // go to next matrix (3rd dimension)
        ghat += constant11;
        // reset pointer fhat
        fhat = iter_fhat;
        // use next column of Wigner-d matrix
        wigd += constant2;
      }
      
      // reset pointer ghat to ghat(-N,-N,-N) when fullsized. ghat(-N,0,-N) otherwise
      ghat = start_ghat;
      // Set pointer fhat to first value in next harmonic degree
      fhat += constant12;
      
      // Change the pointers (wigd, wigdmin1 and wigdmin2) for the next
      // recursions step for the calculation of the Wigner-d matrices.
      // Therefore the two most recently computed Wigner-d matrices are
      // used for next recursion.
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
    ghat_back = ghat + constant5;
    
    // boolean plusminus variable for j>0, because ghat(:,:,j) = ghat(:,:,j)
    // except for the sign.
    // start_pm is the up right start sign (only not true if matrix starts
    // in column with index 0 and bandwidth is an odd value)
    bool start_pm = true;
    if( ((N % 2) == 1) && (fullsized == 0) )
      start_pm = false;
    bool pm = start_pm;
    
    // Calculate Wigner-d matrix
    wigner_d(N,N,wigd_min2,wigd_min1,wigd);
    
    // Shift to middle of first column of Wigner-d matrix.
    wigd += N;
    
    // Set pointer fhat to first value and set helping pointer for iterations
    fhat += halfsized*(2*N+1)*N;
    iter_fhat = fhat;
    
    // Compute ghat by adding over all summands of current harmonic degree N
    for (j=-N; j<=0; j++)
    {
      test1 = (j!=0);
      for (k=-constant1; k<=N; k++)
      {
        test2 = ((k==0) && full);
        for (l=-N; l<=N; l++)
        {
          // compute values
          value = wigd[k]*wigd[l];
          
          // Set value for j<=0
          ghat[0].real += fhat[0].real*value;
          ghat[0].imag += fhat[0].imag*value;
          
          // Set ghat(:,0,:) values to half if not fullsized
            if(test2)
            {
              ghat[0].real = ghat[0].real/2;
              ghat[0].imag = ghat[0].imag/2;
            }
            
          // Fill values for j>0 by symmetry property
            if(test1)
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
          
          // go to next row
          ghat ++; ghat_back ++;
          fhat ++;
        }
        // go to next column
        ghat += row_shift; ghat_back += row_shift;
      }
      // go to next matrix (3rd dimension)
      ghat += constant3;
      ghat_back += constant4;
      
      // reset pointer fhat
      fhat = iter_fhat;
      
      // use next column of Wigner-d matrix
      wigd += constant2;
      
      // reset plusminus to start plusminus value, because in next matrix
      // up right sign is same as before
      pm = start_pm;
    }

//     
// // plot routine for last created Wigner-d matrix
//     wigd = start_wigd;
//     ghat = start_ghat;
//     int matrix = (2*N+2)*(2*N+2); // size
//     ghat -= matrix;               // reset pointer start
//     
//     //mwSize k;
//     for (k=-N; k<=0; k++){
//       for (l=-N; l<=N; l++){
//         ghat[0].real = *wigd;
//         ghat += 1;
//         wigd++;
//       }
//       ghat++;
//     }

}




// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  
  // variable declarations
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // nrows x 1 input coefficient vector
    size_t nrows;                     // size of inCoeff
    char *flag1 = "empty";            // optional input options
    char *flag2 = "empty";
    mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix
    
    
  // check data types
    // check for 2,3 or 4 input arguments (inCoeff & bandwith)
    if( (nrhs!=2) && (nrhs!=3) && (nrhs!=4) )
      mexErrMsgIdAndTxt("calculate_ghat:invalidNumInputs","Two, three or four inputs required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("calculate_ghat:maxlhs","One output required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("calculate_ghat:notDouble","First input argument bandwidth must be a Scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("calculate_ghat:notDouble","Second input argument coefficient vector must be type double.");
    // check that number of columns in second input argument (inCoeff) is 1
    if(mxGetN(prhs[1])!=1)
      mexErrMsgIdAndTxt("calculate_ghat:inputNotVector","Second input argument coefficient vector must be a row vector.");
    
    // make sure the third and fourth input arguments are strings (if existing)
    if ( (nrhs>2) && (mxIsChar(prhs[2]) != 1) )
      mexErrMsgIdAndTxt( "calculate_ghat:notString","Third input argument must be a string.");
    if ( (nrhs>3) && (mxIsChar(prhs[3]) != 1) )
      mexErrMsgIdAndTxt( "calculate_ghat:notString","Fourth input argument must be a string.");
    
    
  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("calculate_ghat:notInt","First input argument must be a natural number.");
    
    // make input matrix complex
    mxArray *zeiger = mxDuplicateArray(prhs[1]);
    if(mxMakeArrayComplex(zeiger)) {}
    
    // create a pointer to the data in the input vector (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);
    
    // get dimensions of the input vector
    nrows = mxGetM(prhs[1]);
    
    // if exists, get flags of input
    if(nrhs>2)
      flag1 = mxArrayToString(prhs[2]);
    if(nrhs>3)
      flag2 = mxArrayToString(prhs[3]);
    
    
  // Get optional flags to generate output with suitable size.
    // If f is a real valued function, then half size in 2nd dimension of
    // ghat is sufficient. Sometimes it is necessary to add zeros in some
    // dimensions to get even size for nfft.
    // define some {0,1}-valued variables.
    int row_shift;    // 1 if zero row are added to make size of ghat even. 0 otherwise
    int col_shift;    // 1 if zero column are added to make size of ghat even. 0 otherwise
    int fullsized;    // 0 if ghat is halfsized in second dimension. 1 otherwise
    
    // define length of the 3 dimensions of ghat
    mwSize dims[3];
    
    // define helping variables
    const int bwp1 = bandwidth+1;
    int start_shift;
    
    if( (!strcmp(flag1,"makeeven")) || (!strcmp(flag2,"makeeven")) )
    {
      // create half sized ghat with even dimensions
      if( (!strcmp(flag1,"isReal")) || (!strcmp(flag2,"isReal")) )
      {
        row_shift = 1;
        col_shift = bwp1 % 2;
        fullsized = 0;
        dims[0] = 2*bandwidth+2;
        dims[1] = bandwidth+1+col_shift;
        dims[2] = 2*bandwidth+2;
        start_shift = (dims[0])*(dims[1]+col_shift)+1;
      }
      // create full sized ghat with even dimensions
      else
      {
        row_shift = 1;
        col_shift = 1;
        fullsized = 1;
        dims[0] = 2*bandwidth+2;
        dims[1] = 2*bandwidth+2;
        dims[2] = 2*bandwidth+2;
        start_shift = (dims[0])*(dims[1]+1)+1;
      }
    }
    else
    {
      // create half sized ghat without additional zeros
      if( (!strcmp(flag1,"isReal")) || (!strcmp(flag2,"isReal")) )
      {
        row_shift = 0;
        col_shift = 0;
        fullsized = 0;
        dims[0] = 2*bandwidth+1;
        dims[1] = bandwidth+1;
        dims[2] = 2*bandwidth+1;
        start_shift = 0;
      }
      // create full sized ghat without additional zeros
      else
      {
        row_shift = 0;
        col_shift = 0;
        fullsized = 1;
        dims[0] = 2*bandwidth+1;
        dims[1] = 2*bandwidth+1;
        dims[2] = 2*bandwidth+1;
        start_shift = 0;
      }
    }
    
    
  // create output data
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxCOMPLEX);
    
    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);
    // set pointer to skip first index
    outFourierCoeff += start_shift;
    
    
  // call the computational routine
    calculate_ghat_longwig(bandwidth,inCoeff,row_shift,col_shift,fullsized,
            outFourierCoeff,(mwSize)nrows);

}