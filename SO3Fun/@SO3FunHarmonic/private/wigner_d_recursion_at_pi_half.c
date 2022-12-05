/* 
 * The Wigner-d matrix of order L, is a matrix with entries from -L:L in
 * both dimensions. Here it is sufficient to calculate Wigner-d with
 * second Euler angle beta = pi/2. Due to symmetry only the columns -L...0 
 * are needed.
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
 * Idea: We construct the current Wigner-d matrix by three term recurrence relation.
 * (refer Antje Vollrath - A Fast Fourier Algorithm on the Rotation Group, section 2.3) [*1*]
 * Therefore we are not able to produce the exterior frame (first and last row an column).
 * Since beta = pi/2 we get this exterior frame very easily by
 * representation of Wigner-d matrices with Jacobi Polynomials.
 * (refer Varshalovich - Quantum Theory of Angular Momentum - 1988, section 4.3.4)      [*2*]
 */

static void wigner_d_recursion_at_pi_half(int N, int L,mxDouble *d_min2,mxDouble *d_min1,mxDouble *d)
{

    int row,col;      // row and column index
    double value;
    
    // shift the pointer to d(-L,-L).
    int shift = 2*(N+1)*(N-L);
    d += shift;
    
    // define pointers for symmetric values
    mxDouble *upright, *downright, *downleft;
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
    const double col_len = 2.0*L+1;
    
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
    
    for (row= -L+1; row<=0; row++)
    {
      sqrt_binom = sqrt_binom * sqrt((col_len-iter)/iter);
      
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
    const int L_square = L*L;
    const int L_min1 = L-1;
    const int L_min1_square = L_min1*L_min1;
    const double constant1 = -(2.0*L-1);
    const double minL = -1.0*L;
    int row_square, col_square;
    long long int constant2, constant3;
    
    // only iterate over lower triangular matrix of A in the loop
    for (col=-L+1; col<=0; col++)
    {
      for (row=col; row<=0; row++)
      {
        // calculate the auxiliar variables v,w similar as in reference [*1*].
        row_square = row*row;
        col_square = col*col;
        constant2 = (L_square-row_square);
        constant3 = (L_square-col_square);
        nenner = sqrt(constant2*constant3) * L_min1;
        v = constant1*row*col / nenner;
        constant2 = (L_min1_square-row_square);
        constant3 = (L_min1_square-col_square);
        w = minL * sqrt(constant2*constant3) / nenner;
        
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
