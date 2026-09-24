/*
 * Wigner-d matrices d^n(r,c) of degree n at beta = pi/2 as the quadrant
 *   S(a,b) = d^n(-a,-b),   0 <= a,b <= n,
 * stored column by column with the fixed column length N+1, S(a,b) at index
 * b*(N+1)+a, so that an entry has the same index in every degree. The
 * symmetries
 *   d^n(c,r)  = (-1)^(r+c)   d^n(r,c),
 *   d^n(-r,c) = (-1)^(n+r+c) d^n(r,c)
 * give the whole matrix from this quadrant, and d^n(0,c) = 0 for odd n+c.
 *
 * The three term recursion of degree n from n-1 and n-2 and the exterior
 * frame of column n from the Jacobi representation are the ones of
 * wigner_d_recursion_at_pi_half.cpp, which also explains why the frame is
 * built as (mantissa,exponent) pair. The recursion is symmetric in (a,b), so
 * computing the whole quadrant gives the same values as mirroring the lower
 * triangle, while every column is a contiguous loop.
 *
 * Entries outside the quadrant of the current degree have to be zero, i.e.
 * the buffers start zeroed and a buffer only ever holds lower degrees.
 */

#include <vector>
#include <cmath>

template<typename T>
static void wigner_d_quadrant_at_pi_half(int N, int L, const T* s2, const T* s1, T* s)
{
  const size_t ld = N+1;

  if (L == 0) { s[0] = 1; return; }
  if (L == 1)
  {
    const T h = std::sqrt((T)0.5);
    s[0] = 0; s[1] = -h; s[ld] = h; s[ld+1] = (T)0.5;
    return;
  }

  // exterior frame: column L from sqrt(binom(2L,L+m)) * 2^(-L), row L by symmetry
  T* col = s + L*ld;
  col[L] = std::ldexp((T)1,-L);
  T mantissa = 1;
  int exponent = 0, e;
  for (int iter = 1; iter <= L; iter++)
  {
    mantissa *= std::sqrt((2*(T)L+1-iter)/(T)iter);
    mantissa = std::frexp(mantissa,&e);
    exponent += e;
    col[L-iter] = std::ldexp(mantissa,exponent-L);
  }
  for (int b = 0; b < L; b++)
    s[b*ld+L] = ((L+b) % 2) ? -col[b] : col[b];

  // inner part by d^L = v*d^(L-1) + w*d^(L-2) with v,w split into a row and a
  // column factor p, q, see wigner_d_recursion_at_pi_half.cpp
  const T c_v = -(2*(T)L-1)/((T)L-1);
  const T c_w = -(T)L/((T)L-1);
  std::vector<T> p(L), q(L);
  for (int a = 0; a < L; a++)
  {
    const T inv = 1/((T)L*(T)L - (T)a*(T)a);
    p[a] = -(T)a * std::sqrt(inv);
    q[a] = std::sqrt((((T)L-1)*((T)L-1) - (T)a*(T)a) * inv);
  }

  #pragma omp parallel for schedule(static) if(L >= 128)
  for (int b = 0; b < L; b++)
  {
    const T v = c_v * p[b], w = c_w * q[b];
    const size_t o = b*ld;
    for (int a = 0; a < L; a++)
      s[o+a] = (v * p[a]) * s1[o+a] + (w * q[a]) * s2[o+a];
  }
}
