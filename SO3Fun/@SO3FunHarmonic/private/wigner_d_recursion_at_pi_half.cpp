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
 *
 * DYNAMIC RANGE. The exterior frame of degree L is
 *        d^L(-L,m) = +-2^(-L) * sqrt(binom(2*L,L+m)),
 * whose corner entries are as small as 2^(-L). These tiny seeds are not
 * negligible: the three term recursion in L decouples over (row,col), so
 * every entry (row,col) is seeded exactly once - by the frame of degree
 * L = max(|row|,|col|) - and then grows to O(L^(-1/2)) as L increases.
 * If a seed underflows to 0, the recursion v*0 + w*0 keeps that entry at 0
 * for all higher degrees, i.e. a whole corner region of the final matrix is
 * silently wiped out. In double precision (2^(-1074) is the smallest
 * subnormal) this destroys the transform from about N = 1500 on.
 * Therefore
 *   - the frame is built as (mantissa,exponent) pair via frexp/ldexp, which
 *     keeps the running product of binomial factors in range independently
 *     of the exponent (and is more accurate than exp(log(...)) too), and
 *   - all intermediate values are of the storage type T, so that calling
 *     this function with T = long double really does extend the exponent
 *     range (up to N of about 16000) instead of rounding back to double in
 *     every recursion step.
 */

// std::sqrt, std::frexp and std::ldexp are overloaded for long double, so
// every intermediate below stays in the storage type T.

#include <vector>
#include <cmath>

template<typename T>
static void wigner_d_recursion_at_pi_half(int N, int L,T* d_min2,T* d_min1,T* d)
{

    int row,col;      // row and column index
    T value;

    // shift the pointer to d(-L,-L).
    int shift = 2*(N+1)*(N-L);
    d += shift;

    // define pointers for symmetric values
    T* upright, *downright, *downleft;
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
    // The product sqrt_binom grows up to about 2^L and hence overflows for
    // large L, while the frame entries themselves stay below 1. So we keep
    // the product as mantissa in [0.5,1) together with a separate integer
    // exponent and only assemble the entry by ldexp at the very end. This
    // way neither the product nor the factor 2^(-L) can run out of range.
    T mantissa = 1;               // sqrt_binom = mantissa * 2^exponent
    int exponent = 0;
    int frexp_exponent;
    const T col_len = 2*(T)L+1;

    // Set first value in up right corner, because binomial coefficient
    // (2*L 0) = 1.  Note that ldexp is exact, in contrast to pow(0.5,L).
    const T multi = std::ldexp((T)1,-L);
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
      // multiply the next factor of sqrt_binom and renormalize the mantissa
      mantissa *= std::sqrt((col_len-iter)/(T)iter);
      mantissa = std::frexp(mantissa,&frexp_exponent);
      exponent += frexp_exponent;

      // frame entry = sqrt_binom * 2^(-L)
      value = std::ldexp(mantissa,exponent-L);

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
    // The coefficients v,w of the recursion formula in reference [*1*],
    //   d^L(row,col) = v * d^(L-1)(row,col) + w * d^(L-2)(row,col),
    //   v = -(2L-1)*row*col / ( (L-1)*sqrt( (L^2-row^2)*(L^2-col^2) ) )
    //   w = -L*sqrt( ((L-1)^2-row^2)*((L-1)^2-col^2) )
    //          / ( (L-1)*sqrt( (L^2-row^2)*(L^2-col^2) ) ),
    // separate into a row and a column factor,
    //   v = c_v * p(row) * p(col),   p(m) = m / sqrt(L^2-m^2)
    //   w = c_w * q(row) * q(col),   q(m) = sqrt( ((L-1)^2-m^2)/(L^2-m^2) ).
    // Precomputing p,q once per degree replaces the two square roots and
    // the division per matrix entry by plain multiplications.
    // Note that |row|,|col| <= L-1 here, so no denominator vanishes, and
    // q(+-(L-1)) = 0 reproduces the exact zeros of the old formula.
    const T c_v = -(2*(T)L-1)/((T)L-1);
    const T c_w = -(T)L/((T)L-1);
    std::vector<T> pfac(L), qfac(L);
    for (int m=-L+1; m<=0; m++)
    {
      const T m_square = (T)m*(T)m;
      const T inv = 1/((T)L*(T)L - m_square);
      pfac[m+L-1] = (T)m * std::sqrt(inv);
      qfac[m+L-1] = std::sqrt((((T)L-1)*((T)L-1) - m_square) * inv);
    }

    // only iterate over lower triangular matrix of A in the loop
    for (col=-L+1; col<=0; col++)
    {
      // column part of the recursion coefficients
      const T v_col = c_v * pfac[col+L-1];
      const T w_col = c_w * qfac[col+L-1];
      const T* pRow = pfac.data() + col+L-1;
      const T* qRow = qfac.data() + col+L-1;

      for (row=col; row<=0; row++)
      {
        // get the value of inner part
        value = (v_col * *pRow) * (*d_min1) + (w_col * *qRow) * (*d_min2);

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
        d ++; d_min1 ++; d_min2 ++; downleft --; pRow ++; qRow ++;
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
