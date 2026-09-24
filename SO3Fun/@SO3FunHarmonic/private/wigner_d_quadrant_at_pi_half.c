/*
 * C version for double of wigner_d_quadrant_at_pi_half.cpp, see there:
 * the Wigner-d matrix of degree L at beta = pi/2 as the quadrant
 *   S(a,b) = d^L(-a,-b),   0 <= a,b <= L,
 * at index b*(N+1)+a, from the quadrants of degrees L-1 and L-2. Entries
 * outside the quadrant of the current degree have to be zero.
 */

#include <math.h>
#include <stdlib.h>

static void wigner_d_quadrant_at_pi_half(int N, int L, const double* s2, const double* s1, double* s)
{
  const size_t ld = N+1;
  int a, b, iter, e, exponent = 0;
  double mantissa = 1;

  if (L == 0) { s[0] = 1; return; }
  if (L == 1)
  {
    const double h = sqrt(0.5);
    s[0] = 0; s[1] = -h; s[ld] = h; s[ld+1] = 0.5;
    return;
  }

  // exterior frame: column L from sqrt(binom(2L,L+m)) * 2^(-L), row L by symmetry
  double* col = s + L*ld;
  col[L] = ldexp(1.0,-L);
  for (iter = 1; iter <= L; iter++)
  {
    mantissa *= sqrt((2*(double)L+1-iter)/(double)iter);
    mantissa = frexp(mantissa,&e);
    exponent += e;
    col[L-iter] = ldexp(mantissa,exponent-L);
  }
  for (b = 0; b < L; b++)
    s[b*ld+L] = ((L+b) % 2) ? -col[b] : col[b];

  // inner part by d^L = v*d^(L-1) + w*d^(L-2) with row and column factors p, q
  const double c_v = -(2*(double)L-1)/((double)L-1);
  const double c_w = -(double)L/((double)L-1);
  double *p = malloc(2*L*sizeof(double)), *q = p + L;
  for (a = 0; a < L; a++)
  {
    const double inv = 1/((double)L*(double)L - (double)a*(double)a);
    p[a] = -(double)a * sqrt(inv);
    q[a] = sqrt((((double)L-1)*((double)L-1) - (double)a*(double)a) * inv);
  }

  #pragma omp parallel for private(a) schedule(static) if(L >= 128)
  for (b = 0; b < L; b++)
  {
    const double v = c_v * p[b], w = c_w * q[b];
    const size_t o = b*ld;
    for (a = 0; a < L; a++)
      s[o+a] = (v * p[a]) * s1[o+a] + (w * q[a]) * s2[o+a];
  }
  free(p);
}

// the columns d^n(k,-j), k = -n..n, of the degrees n0 <= n < n1 of a block,
// at D[((n-n0)*(N+1) + j)*(2N+1) + N + k], from the quadrants in the ring
// buffer S of B+2 degrees, by d^n(k,-j) = (-1)^(n+k+j) S(k,j) for k > 0
static void fill_wigner_d_columns(int N, int n0, int n1, int B, const double* S, double* D)
{
  const size_t ld = N+1, ldD = 2*N+1;
  for (int n = n0; n < n1; n++)
  {
    const double *s = S + (n%(B+2))*ld*ld;
    #pragma omp parallel for schedule(static) if(N >= 128)
    for (int j = 0; j <= n; j++)
    {
      const double *c = s + j*ld;
      double *d = D + ((n-n0)*ld + j)*ldD + N;
      d[0] = c[0];
      for (int k = 1; k <= n; k++)
      {
        d[-k] = c[k];
        d[k] = ((n+k+j) & 1) ? -c[k] : c[k];
      }
    }
  }
}
