/*=========================================================================
 * 
 * Compute a Wigner-d matrix by recursion formula.
 * Therefore it is possible to generate a Wigner-d matrix by input of the
 * two Wigner-d matrices with next smaller harmonic degree. It is also
 * possible to calculate a Wigner-d matrix of a given harmonic degree L by
 * recursions formula.
 * 
 * Syntax
 *   d = Wigner_d_fast(dlmin1,dlmin2,beta)
 *   d = Wigner_d_fast(L,beta)
 * 
 * Input
 *   L             - harmonic degree
 *   beta          - second Euler angle
 *   dlmin1,dlmin2 - Wigner-d matrices of harmonic degree L-1 and L-2
 * 
 * Output
 *   d - Wigner d matrix of harmonic degree L
 * 
 * Example
 *   d = Wigner_d_fast(Wigner_D(4,pi/2),Wigner_D(3,pi/2),pi/2)
 *   d = Wigner_d_fast(64,pi/2)
 *
 * Tip: If 2nd Euler angle beta is unknown, it can be computed simply by:
 *            d^L(-L,-L) = cos(beta/2)^(2*L)
 *      where d^L is a Wigner-d Matrix with harmonic degree L and 
 *      d^L(-L,-L) is its up left value.
 * 
 * 
 * This is a MEX-file for MATLAB.
 * 
 *=========================================================================
 */

#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <stdio.h>

// The Wigner D-matrix of order L, is a matrix with entries from -L:L in
// both dimensions.
// 
// Idea: We construct the current Wigner-d matrix by three term recurrsion.
// (refer Antje Vollrath - A Fast Fourier Algorithm on the Rotation Group, section 2.3) [*1*]
// Therefore we can not produce the first and last row and column. But we
// get this exterior frame very easily by representation of Wigner-d matrix
// with Jacobi Polynomials.
// (refer Varshalovich - Quantum Theory of Angular Momentum - 1988, section 4.3.4)      [*2*]
// Because of symmetry properties it is sufficient to calculate the right 
// part of the Wigner-d matrix, look:
//        (  A  |  B* )        + (the cross) represents row and column with index 0
//    d = ( ----+---- )        * corresponds to flip(flip(.,1),2)
//        (  B  |  A* )
// Moreover A is a symmetric matrix and B is anti-symmetric. Hence we only
// calculate the lower triangular part of A including (--+) the left part
// of the row with column index 0 and the upper anti-triangular matrix of B, look:
//    ( x             )
//    ( x x           )
//    ( x x x         )
//    ( - - - +       )
//    ( x x x         )
//    ( x x           )
//    ( x             )
// All in all we calculate only this representative triangle in every
// recursions step. At the end we use symmetry to fill the whole Wigner-d 
// matrix. So the boolean input variable fullsized is motivated.
static void wigner_d_recursionsstep(const int N, const int L, const double beta, 
        const bool fullsized, mxDouble *d_min2_up, mxDouble *d_min1_up,
        mxDouble *upleft)
{
  // define variables, indices and pointers
    int col;                        // column index
    int row;                        // row index
    int iter;                       // running index
    double value_up, value_down;    // variables to compute for row<=0 and
                                    // row>0 seperately
    int shift, shift2;              // variables for shifting pointers
    
    // define pointer which is used at the end for col>0 if fullsized
    mxDouble *sym;
    sym = upleft;
    
    // shift the output pointer to d(-L,-L).
    shift = (2*N+2)*(N-L);
    upleft += shift;
    
    // define pointers for symmetric values for col<=0. There are also down
    // values for d_min1 and d_min2 needed.
    mxDouble *upright;
    mxDouble *downright;
    mxDouble *downleft;
    mxDouble *d_min1_down;
    mxDouble *d_min2_down;
    upright = upleft;
    downleft = upleft+2*L;
    downright = downleft;
    
    // Two pointers run over column indices. Updating is done by shifting
    const int column_shift = 2*N+1;

    
  // Produce the exterior frame (row L and column -L) without recursion
  // formula by:
    // Representation formula of Wigner-d matrices with Jacobi Polynomials
    // The column -L is iteratively calculated by: 
    //    cos(beta/2)^(L-row) * sin(beta/2)^(L+row) * sqrt_binom.
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
    const double constant1 = 2.0*L+1;
    // We describe  cos(beta/2)^(L-row) * sin(beta/2)^(L+row) by a sequence
    // cos(beta/2)^(2*L)
    // cos(beta/2)^(2*L) * tan(beta/2)
    // cos(beta/2)^(2*L) * tan(beta/2) * tan(beta/2)
    // cos(beta/2)^(2*L) * tan(beta/2) * tan(beta/2) * tan(beta/2)
    // ...
    // sin(beta/2)^(2*L) * 1/tan(beta/2) * 1/tan(beta/2)
    // sin(beta/2)^(2*L) * 1/tan(beta/2)
    // sin(beta/2)^(2*L)
    const double sinus = sin(0.5*beta);
    const double cosinus = cos(0.5*beta);
    const double tangens = tan(0.5*beta);
    const double cotangens = 1/tangens;
    double top = pow(cosinus,2*L);
    double bottom = pow(sinus,2*L);
    
    // Set first value in up right corner, because binomial coefficient
    // (2*L 0) = 1.
    *upleft = top;
    
    // Set symmetrically value in down left corner (pay attention to sign)
    if (L % 2 == 0)
      *downleft = bottom;
    else
      *downleft = -bottom;
    
    // update the pointers
    upleft ++;
    downleft --;
    upright += column_shift;
    downright += column_shift;
    
    // define running index
    iter=1;
    
    // Set values in outer frame by iterating over column -L
    for (row=-L+1; row<=0; row++)
    {
      // Update the iterative variables
      sqrt_binom = sqrt_binom * sqrt((constant1-iter)/iter);
      top = top * tangens;
      bottom = bottom * cotangens;
      
      // calculate Wigner-d values (row,-L) and (-row,-L)
      value_up = sqrt_binom * top;
      value_down = sqrt_binom * bottom;
      
    // Use symmetry and set the value 4 times with some signs.
      // 1.) Set value_up in lower triangular matrix of A
      *upleft = value_up;
      
      // 2.) Set value_down in upper anti-triangular matrix of A* with same 
      //     column index as the previous value (1).
      if ((L+iter) % 2 == 0)
        *downleft = value_down;
      else
        *downleft = -value_down;
      
      // Only set the two other values if full Wigner-d matrix is needed.
      if (fullsized)
      {
        // 3.) Set value_up in upper triangular matrix of A (symmetric to (1) in A).
        if ((iter % 2) == 0)
          *upright = value_up;
        else
          *upright = -value_up;
        
        // 4.) Set value_down in lower anti-triangular matrix of A* with 
        //     same column index as the previous value (3).
        if ((L % 2) == 0)
          *downright = value_down;
        else
          *downright = -value_down;
      
        // Update pointers to next value
        upright += column_shift;
        downright += column_shift;
      }
      
      // increase running index
      iter++;
      
      // Update pointers to next value
      upleft ++;
      downleft --;
    }
    
    // shift to diagonal element (-L+1,-L+1) of output Wigner-d matrix
    shift2 = 2*(N+1)*(N-L+1);
    d_min1_up += shift2;
    d_min2_up += shift2;
    shift = 2*N-L+1;
    upleft += shift;
    upright = upleft;
    // and to diagonal element (L-1,-L+1) for lower values
    shift2 = 2*L-2;
    downleft = upleft + shift2;
    downright = downleft;
    d_min1_down = d_min1_up + shift2;
    d_min2_down = d_min2_up + shift2;
    
    
  // Now do three term recursion to receive inner part of Wigner-d matrix.
    // define some variables for computing Wigner-d by recursion formula
    double nenner,u,v,w;
    const int constant2 = L*L;
    const int constant3 = L-1;
    const int constant4 = constant3*constant3;
    const double constant11 = cos(beta)*L*(2*L-1);
    const double constant5 = -(2.0*L-1);
    const double constant6 = -1.0*L;
    int constant7, constant8;
    long long int constant9, constant10;
    
    // only iterate over lower triangular matrix of A in the loop
    for (col=-L+1; col<=0; col++)
    {
      for (row=col; row<=0; row++)
      {
        // calculate the auxiliar variables cos(beta)*u, v, w similar as in reference [*1*].
        constant7 = row*row;
        constant8 = col*col;
        constant9 = (constant2-constant7);
        constant10 = (constant2-constant8);
        nenner = sqrt(constant9*constant10);
        u = constant11/nenner;
        nenner = nenner * constant3;
        v = constant5*row*col / nenner;
        constant9 = (constant4-constant7);
        constant10 = (constant4-constant8);
        w = constant6 * sqrt(constant9*constant10) / nenner;
        
        // get two values of inner part: (row,col) and (-row,col)
        value_up = (u+v)*(*d_min1_up) + w*(*d_min2_up);
        value_down = (u-v)*(*d_min1_down) + w*(*d_min2_down);
        
        // Set this values at every symmetric point where it occurs for col<=0 (4 times).
        // Pay attention to different signs.
        // 1.) Set value in lower triangular matrix of A
        *upleft = value_up;
        
        // 2.) Set value in upper anti-triangular matrix of A* with same 
        //     column index as the previous value (1)
        if (row != 0)
          *downleft = value_down;
        
        // 3.) Set value in upper triangular matrix of A (symmetric in A to (1))
        // 4.) Set value in lower anti-triangular matrix of A* with same 
        //     column index as previous value (3).
        if (fullsized)
        {
          if (row != col)
          {
            if ((row+col) % 2 == 0)
            {
              *upright = value_up;        // (3)
              *downright = value_down;    // (4)
            }
            else
            {
              *upright = -value_up;       // (3)
              *downright = -value_down;   // (4)
            }
          }
          
          // Update pointers for next iteration in next column and same row
          upright += column_shift;
          downright += column_shift;
        }
        
        // Update pointers for next iteration in same column and next row
        upleft ++;
        d_min1_up ++;
        d_min2_up ++;
        downleft --;
        d_min1_down --;
        d_min2_down --;
      }
      
      // Update pointers for next iteration in next column
      shift ++;
      upleft += shift;
      d_min1_up += shift;
      d_min2_up += shift;
      shift2 = 2*col+2;
      downleft = upleft - shift2;
      d_min1_down = d_min1_up - shift2;
      d_min2_down = d_min2_up - shift2;
      // or in next row
      upright = upleft;
      downright = downleft;
    }
    
  // If fullsized add the values for col>0 by iterating over all other values.
    if (fullsized)
    {
      upleft = sym;
      sym += (2*N+1)*(2*N+1)-1;
      for (iter=1; iter<=(2*N+1)*N; iter++)
      {
        *sym = *upleft;
        sym --;
        upleft ++;
      }
    }

}






// The computational routine for calculating one Wigner-d matrix from 
// input bandwidth and Euler angle. We use the upper function for the 
// recursionsstep.
 static void wigner_d(const int N, const mxDouble beta, mxDouble *outWigner)
{
   
   int row, col, n;     // variables for iterating
   int shift;           // variables for shifting pointers

  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      *outWigner = 1;
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
    
        
  // Start with n=0 and n=1 manually and use a loop for the remaining n > 1,
  // except the last one. Do the last iteration n=N seperately and use 
  // symmetry of Wigner-d here.
    
    // Set start values for recurrence relations to compute Wigner-d matrices
    // Wigner_d(0,beta)
    shift = 2*(N+1)*N;
    wigd_min2 += shift;           // go to last column and center row of matrix *
    *wigd_min2 = 1;
    wigd_min2 = start_wigd_min2;  // go back to matrix start
    
    // Wigner_d(1,beta)
    shift = 2*(N+1)*(N-1);
    wigd_min1 += shift;           // go 1 left up from *
    const double sq = sqrt(0.5);
    const double cosinus = cos(beta);
    const double sinus = sin(beta);
    const double wigd_harmonicdegree1[3][3] = { // values of Wigner_d(1,beta)
      { 0.5*(1+cosinus) , -sq*sinus , -0.5*(1-cosinus) },
      {    sq*sinus     ,  cosinus  ,    sq*sinus    },
      {-0.5*(1-cosinus) , -sq*sinus ,  0.5*(1+cosinus) }    };
    shift = 2*(N-1);
    for (col=0; col<2; col++)
    {
      for (row=0; row<3; row++)
      {
        *wigd_min1 = wigd_harmonicdegree1[row][col];  // fill with values
        wigd_min1 ++;                                 // go to next row
      }
      wigd_min1 += shift;                             // go to next column
    }
    wigd_min1 = start_wigd_min1;                      // go back to matrix start
    
    
  // Be shure N>1, otherwise STOP.
    if (N==1)
    {
      for (col=0; col<3; col++)
      {
        for (row=0; row<3; row++)
        {
          *outWigner = wigd_harmonicdegree1[row][col];
          *outWigner ++;
        }
      }
      
      return;
    }
    
    
  // Do recursion for 1 < n < N:
    for (n=2; n<N; n++)
    {
      // Calculate Wigner-d matrix wigd with bandwidth n contained in a matrix 
      // of size (2N+1)x(2N+1) zeros. As input we use the previous two 
      // Wigner-d matrices for recursions formula.
      // false means: representative quarter of Wigner-d matrix is sufficient.
      wigner_d_recursionsstep(N,n,beta,false,wigd_min2,wigd_min1,wigd);
      
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
    
    
  // Do step for n=N and set symmetric values for col>0 by copying from col<0
    // Calculate Wigner-d matrix wigd with bandwidth n contained in a matrix 
    // of size (2N+1)x(2N+1) zeros. As input we use the previous two 
    // Wigner-d matrices for recursions formula.
    // true means: full Wigner-d matrix is expected.
    wigner_d_recursionsstep(N,N,beta,true,wigd_min2,wigd_min1,outWigner);

}






// Calculate the new Wigner-d matrix with bandwidth N by two given matrices
// with bandwidths N-1 and N-2. Notice that d_min1 is of size (2*N-1)x(2*N-1)
// and d_min2 is size (2*N-3)x(2*N-3).
// Probably they are halfsized in 2nd dimension. Then the new Wigner-d
// matrix should be also halfsized.
// For computing idea look at the top function wigner_d_recursionsstep.
static void wigner_d_onestep(const int N, const double beta, const bool fullsized,
        mxDouble *d_min2_up, mxDouble *d_min1_up, mxDouble *upleft)
{
  // define variables, indices and pointers
    int col;                        // column index
    int row;                        // row index
    int iter;                       // running index
    double value_up, value_down;    // variables to compute for row<=0 and
                                    // row>0 seperately
    int shift, shift2;              // variables for shifting pointers
    
    // define pointer which is used at the end for col>0 if fullsized
    mxDouble *sym;
    sym = upleft;
    
    // The output pointer is already at d(-N,-N). Hence shifting is not necessary.
    
    // define pointers for symmetric values for col<=0. There are also down
    // values for d_min1 and d_min2 needed.
    mxDouble *upright;
    mxDouble *downright;
    mxDouble *downleft;
    mxDouble *d_min1_down;
    mxDouble *d_min2_down;
    upright = upleft;
    downleft = upleft+2*N;
    downright = downleft;
    
    // Two pointers run over column indices. Updating is done by shifting
    const int column_shift = 2*N+1;

    
  // Produce the exterior frame (row N and column -N) without recursion
  // formula by:
    // Representation formula of Wigner-d matrices with Jacobi Polynomials
    // The column -N is iteratively calculated by: 
    //    cos(beta/2)^(N-row) * sin(beta/2)^(N+row) * sqrt_binom.
    // sqrt_binom = sequence with square roots of binomial coefficents
    // (2*N  0), (2*N 1), ... (2*N  (N+row)).
    // For instance we use N=10. We can write the sequence as square roots of:
    // 1
    // (10/1)
    // (10/1) * (9/2)
    // (10/1) * (9/2) * (8/3)
    // (10/1) * (9/2) * (8/3) * (7/4)
    // ...
    // Therefore we start with 1 and every new entry needs a multiplication
    // with next factor.
    double sqrt_binom = 1;
    const double constant1 = 2.0*N+1;
    // We describe  cos(beta/2)^(N-row) * sin(beta/2)^(N+row) by a sequence
    // cos(beta/2)^(2*N)
    // cos(beta/2)^(2*N) * tan(beta/2)
    // cos(beta/2)^(2*N) * tan(beta/2) * tan(beta/2)
    // cos(beta/2)^(2*N) * tan(beta/2) * tan(beta/2) * tan(beta/2)
    // ...
    // sin(beta/2)^(2*N) * 1/tan(beta/2) * 1/tan(beta/2)
    // sin(beta/2)^(2*N) * 1/tan(beta/2)
    // sin(beta/2)^(2*N)
    const double sinus = sin(0.5*beta);
    const double cosinus = cos(0.5*beta);
    const double tangens = tan(0.5*beta);
    const double cotangens = 1/tangens;
    double top = pow(cosinus,2*N);
    double bottom = pow(sinus,2*N);
    
    // Set first value in up right corner, because binomial coefficient
    // (2*N 0) = 1.
    *upleft = top;
    
    // Set symmetrically value in down left corner (pay attention to sign)
    if (N % 2 == 0)
      *downleft = bottom;
    else
      *downleft = -bottom;
    
    // update the pointers
    upleft ++;
    downleft --;
    upright += column_shift;
    downright += column_shift;
    
    // define running index
    iter=1;
    
    // Set values in outer frame by iterating over column -N
    for (row=-N+1; row<=0; row++)
    {
      // Update the iterative variables
      sqrt_binom = sqrt_binom * sqrt((constant1-iter)/iter);
      top = top * tangens;
      bottom = bottom * cotangens;
      
      // calculate Wigner-d values (row,-N) and (-row,-N)
      value_up = sqrt_binom * top;
      value_down = sqrt_binom * bottom;
      
    // Use symmetry and set the value 4 times with some signs.
      // 1.) Set value_up in lower triangular matrix of A
      *upleft = value_up;
      
      // 2.) Set value_down in upper anti-triangular matrix of A* with same 
      //     column index as the previous value (1).
      if ((N+iter) % 2 == 0)
        *downleft = value_down;
      else
        *downleft = -value_down;
      
      // 3.) Set value_up in upper triangular matrix of A (symmetric to (1) in A).
      if ((iter % 2) == 0)
        *upright = value_up;
      else
        *upright = -value_up;
      
      // 4.) Set value_down in lower anti-triangular matrix of A* with 
      //     same column index as the previous value (3).
      if ((N % 2) == 0)
        *downright = value_down;
      else
        *downright = -value_down;
      
      // increase running index
      iter++;
      
      // Update pointers to next value
      upleft ++;
      upright += column_shift;
      downleft --;
      downright += column_shift;
    }
    
    // shift to diagonal element (-N+1,-N+1) of output Wigner-d matrix
    shift = N+1;
    upleft += shift;
    upright = upleft;
    // and to diagonal element (N-1,-N+1) for lower values
    shift2 = 2*N-2;
    downleft = upleft + shift2;
    downright = downleft;
    d_min1_down = d_min1_up + shift2;
    d_min2_down = d_min2_up + shift2-2;
    
    
  // Now do three term recursion to receive inner part of Wigner-d matrix.
    // define some variables for computing Wigner-d by recursion formula
    double nenner,u,v,w;
    const int constant2 = N*N;
    const int constant3 = N-1;
    const int constant4 = constant3*constant3;
    const double constant11 = cos(beta)*N*(2*N-1);
    const double constant5 = -(2.0*N-1);
    const double constant6 = -1.0*N;
    int constant7, constant8;
    long long int constant9, constant10;
    
    // only iterate over lower triangular matrix of A in the loop
    for (col=-N+1; col<=0; col++)
    {
      for (row=col; row<=0; row++)
      {
        // calculate the auxiliar variables cos(beta)*u, v, w similar as in reference [*1*].
        constant7 = row*row;
        constant8 = col*col;
        constant9 = (constant2-constant7);
        constant10 = (constant2-constant8);
        nenner = sqrt(constant9*constant10);
        u = constant11/nenner;
        nenner = nenner * constant3;
        v = constant5*row*col / nenner;
        constant9 = (constant4-constant7);
        constant10 = (constant4-constant8);
        w = constant6 * sqrt(constant9*constant10) / nenner;
        
        // get two values of inner part: (row,col) and (-row,col)
        value_up = (u+v)*(*d_min1_up) + w*(*d_min2_up);
        value_down = (u-v)*(*d_min1_down) + w*(*d_min2_down);
        
        // Set this values at every symmetric point where it occurs for col<=0 (4 times).
        // Pay attention to different signs.
        // 1.) Set value in lower triangular matrix of A
        *upleft = value_up;
        
        // 2.) Set value in upper anti-triangular matrix of A* with same 
        //     column index as the previous value (1)
        if (row != 0)
          *downleft = value_down;
        
        // 3.) Set value in upper triangular matrix of A (symmetric in A to (1))
        // 4.) Set value in lower anti-triangular matrix of A* with same 
        //     column index as previous value (3).
        if (row != col)
        {
          if ((row+col) % 2 == 0)
          {
            *upright = value_up;        // (3)
            *downright = value_down;    // (4)
          }
          else
          {
            *upright = -value_up;       // (3)
            *downright = -value_down;   // (4)
          }
        }

        // Update pointers for next iteration in same column and next row
        upleft ++;
        d_min1_up ++;
        downleft --;
        d_min1_down --;
        if ((row != -N+1) && (col != -N+1))
        {
          d_min2_up ++;
          d_min2_down --;
        }
        // or in next column and same row
        upright += column_shift;
        downright += column_shift;
      }
      
      // Update pointers for next iteration in next column
      shift ++;
      upleft += shift;
      d_min1_up += shift-2;
      d_min1_down = d_min1_up - 2*col-2;
      if (col != -N+1)
      {
        d_min2_up += shift-4;
        d_min2_down = d_min2_up - 2*col-2;
      }
      downleft = upleft - 2*col-2;
      // or in next row
      upright = upleft;
      downright = downleft;
    }

    // If fullsized add the values for col>0 by iterating over all other values.
    if (fullsized)
    {
      upleft = sym;
      sym += (2*N+1)*(2*N+1)-1;
      for (iter=1; iter<=(2*N+1)*N; iter++)
      {
        *sym = *upleft;
        sym --;
        upleft ++;
      }
    }

}






// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
  // variable declarations here
    mxDouble bandwidth;           // input bandwidth
    mxDouble *inwigd_min1;        // input Wigner-d with harmonic degree L-1
    mxDouble *inwigd_min2;        // input Wigner-d with harmonic degree L-2
    size_t nrows;                 // size of wigd_min1
    size_t ncolumns;              
    mxDouble beta;                // input beta
    mxDouble *outWigner;          // output Wigner-d matrix
    bool fullsized = true;        // true  when fullsized
                                  // false when halfsized
    bool onestep = false;
    
    
  // check data types
    // check for 2 or 3 input arguments
    if ((nrhs!=2) && (nrhs!=3))
      mexErrMsgIdAndTxt("Wigner_d:invalidNumInputs","Two or three inputs required.");
    // check for 1 output argument (outWigner)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("Wigner_d:maxlhs","One output required.");

    if (nrhs==2)
    {
      // make sure the first input argument (bandwidth) is double scalar
      if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
        mexErrMsgIdAndTxt("Wigner_d:notDouble","Input bandwidth must be a scalar double.");
      
      // make sure the second input argument (second Euler angle - beta) is double scalar
      if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || mxGetNumberOfElements(prhs[1])!=1 )
        mexErrMsgIdAndTxt("Wigner_d:notDouble","Input Euler angle must be a scalar double.");
    }
    else
    {
      // make sure the first input argument (d_min1) is type double
      if( !mxIsComplex(prhs[0]) && !mxIsDouble(prhs[0]) )
        mexErrMsgIdAndTxt("Wigner_d:notInt","Input Wigner-d matrix must be type double.");
      
      // make sure the second input argument (d_min2) is type double
      if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
        mexErrMsgIdAndTxt("Wigner_d:notInt","Input Wigner-d matrix must be type double.");
      
       // make sure the third input argument (second Euler angle - beta) is double scalar
      if( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 )
        mexErrMsgIdAndTxt("Wigner_d:notInt","Input Euler angle must be a scalar double.");
    }
    
    
  // read input data
    if (nrhs==3)
    {
      // Set a boolean variable
      onestep = true;
      
      // create a pointer to the data in the input matrix (inwigd_min1)
      inwigd_min1 = mxGetDoubles(prhs[0]);
      // create a pointer to the data in the input matrix (inwigd_min2)
      inwigd_min2 = mxGetDoubles(prhs[1]);
      
      // get size of the input d_min1 matrix
      nrows = mxGetM(prhs[0]);
      ncolumns = mxGetN(prhs[0]);
      
      // get ishalfsized
      if (nrows != ncolumns)
        fullsized = false;
      
      // compute bandwidth of new Wigner-d matrix
      bandwidth = 1+(nrows-1)/2;

      // get the value of the scalar input Euler angle
      beta = mxGetScalar(prhs[2]);
      
      // check correct size of inwigd_min1 and inwigd_min2
      if(!fullsized)
      {
        if ((nrows != mxGetM(prhs[1])+2) || (ncolumns != mxGetN(prhs[1])+1) || (bandwidth != ncolumns))
          mexErrMsgIdAndTxt("Wigner_d:notInt","aaInput Wigner-d matrices are the wrong size.");
      }
      else
      {
        if ((nrows != mxGetM(prhs[1])+2) || (ncolumns != mxGetN(prhs[1])+2) || (nrows != ncolumns))
          mexErrMsgIdAndTxt("Wigner_d:notInt","Input Wigner-d matrices are the wrong size.");
      }
      
    }
    else
    {
      // get the value of the scalar input bandwidth
      bandwidth = mxGetScalar(prhs[0]);
      
      // check whether bandwidth is natural number
      if( (round(bandwidth)-bandwidth)!=0 || bandwidth<0 )
        mexErrMsgIdAndTxt("Wigner_d:notInt","Input bandwidth must be a natural number.");
      
      // get the value of the scalar input Euler angle
      beta = mxGetScalar(prhs[1]);
    }
    
    // check whether beta is in [0,pi]
    if( beta<0 || beta >M_PI )
      mexErrMsgIdAndTxt("Wigner_d:notindomain","Input Euler angle must be in [0,pi].");
    
    // Get integer bandwidth
    const int N = bandwidth;
    
    
  // create output data
    mwSize length_2;
    if(fullsized)
      length_2 = 2*bandwidth+1;
    else
      length_2 = bandwidth+1;
    
    plhs[0] = mxCreateDoubleMatrix(2*bandwidth+1, length_2,mxREAL);

    // create a pointer to the data in the output array
    outWigner = mxGetDoubles(plhs[0]);

  
  // check whether beta is not 0 or pi. If thats the case return trivial solution
    int k;
    int shift = 2*N+2;
    if(beta==0)
    {
      for (k=-N; k<=N; k++)
      {
        *outWigner = 1;
        outWigner += shift;
      }
      return;
    }
    shift = 2*N;
    if (beta==M_PI)
    {
      outWigner += shift;
      if ((N % 2)==0)
        for (k=-N; k<=N; k++)
        {
          *outWigner = 1;
          outWigner += shift;
        }
      else
        for (k=-N; k<=N; k++)
        {
          *outWigner = -1;
          outWigner += shift;
        }
      return;
    }
    
    
  // call the computational routine
    if(onestep)
      wigner_d_onestep(N,beta,fullsized,inwigd_min2,inwigd_min1,outWigner);
    else
      wigner_d(N,beta,outWigner);

}