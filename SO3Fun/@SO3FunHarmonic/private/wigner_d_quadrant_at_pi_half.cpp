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
 * Every entry is a sequence in the degree of its own, starting at the frame
 * with a value down to 2^-n and growing from there. An entry starting below
 * 2^-1000 would underflow in double, so it is carried as a mantissa and a
 * binary exponent of its own until it has grown above 2^-1000, which is
 * tested every 16 degrees. Meanwhile the quadrant holds 0, below the rounding
 * error of every sum the entry enters, and when it returns to the plain
 * recursion the quadrant of the degree before gets its value too. These
 * entries lie in a band around the diagonal, so every column keeps the rows
 * lo..hi that may carry one, and all other rows run the plain recursion.
 *
 * Entries outside the quadrant of the current degree have to be zero, i.e.
 * the buffers start zeroed and a buffer only ever holds lower degrees.
 */

#include <vector>
#include <cmath>
#include <algorithm>

class WignerQuadrants
{
  static constexpr int small = -1000;  // exponent below which an entry is scaled
  const int N;
  const size_t ld;
  std::vector<double> m1, m2;          // mantissas of the last two degrees
  std::vector<int> e;                  // their common exponent, 0 for a plain entry
  std::vector<int> lo, hi;             // rows of every column that may be scaled

  // the frame entry (a,b) at i = mantissa * 2^ex, 1/2 <= |mantissa| < 1,
  // scaled if it is too small
  double seed(size_t i, int b, int a, double mantissa, int ex)
  {
    if (ex >= small) return std::ldexp(mantissa,ex);
    if (e.empty()) { m1.assign(ld*ld,0); m2.assign(ld*ld,0); e.assign(ld*ld,0); }
    m1[i] = mantissa; m2[i] = 0; e[i] = ex;
    lo[b] = std::min(lo[b],a); hi[b] = std::max(hi[b],a);
    return 0;
  }

public:
  WignerQuadrants(int N) : N(N), ld(N+1), lo(N+1,N+1), hi(N+1,-1) {}

  // the quadrant s of degree L from those of degree L-1 and L-2
  void next(int L, const double* s2, double* s1, double* s)
  {
    if (L == 0) { s[0] = 1; return; }
    if (L == 1)
    {
      const double h = std::sqrt(0.5);
      s[0] = 0; s[1] = -h; s[ld] = h; s[ld+1] = 0.5;
      return;
    }

    // exterior frame: column L from sqrt(binom(2L,L+m)) * 2^(-L), row L by symmetry
    double* col = s + L*ld;
    col[L] = seed(L*ld+L,L,L,0.5,1-L);
    double mantissa = 1;
    int exponent = 0, x;
    for (int iter = 1; iter <= L; iter++)
    {
      mantissa *= std::sqrt((2*(double)L+1-iter)/(double)iter);
      mantissa = std::frexp(mantissa,&x);
      exponent += x;
      const int a = L-iter;
      const double sgn = ((L+a) % 2) ? -1 : 1;
      col[a] = seed(L*ld+a,L,a,mantissa,exponent-L);
      s[a*ld+L] = seed(a*ld+L,a,L,sgn*mantissa,exponent-L);
    }

    // inner part by d^L = v*d^(L-1) + w*d^(L-2) with v,w split into a row and a
    // column factor p, q, see wigner_d_recursion_at_pi_half.cpp
    const double c_v = -(2*(double)L-1)/((double)L-1);
    const double c_w = -(double)L/((double)L-1);
    std::vector<double> p(L), q(L);
    for (int a = 0; a < L; a++)
    {
      const double inv = 1/((double)L*(double)L - (double)a*(double)a);
      p[a] = -(double)a * std::sqrt(inv);
      q[a] = std::sqrt((((double)L-1)*((double)L-1) - (double)a*(double)a) * inv);
    }

    const bool test = L % 16 == 0;
    #pragma omp parallel for schedule(static) if(L >= 128)
    for (int b = 0; b < L; b++)
    {
      const double v = c_v * p[b], w = c_w * q[b];
      const size_t o = b*ld;
      const int l0 = std::min(lo[b],L), h0 = std::min(hi[b],L-1);
      for (int a = 0; a < l0; a++)
        s[o+a] = (v * p[a]) * s1[o+a] + (w * q[a]) * s2[o+a];
      for (int a = l0; a <= h0; a++)
      {
        const size_t i = o+a;
        if (e[i] == 0) { s[i] = (v * p[a]) * s1[i] + (w * q[a]) * s2[i]; continue; }
        const double m = (v * p[a]) * m1[i] + (w * q[a]) * m2[i];
        m2[i] = m1[i]; m1[i] = m; s[i] = 0;
        if (!test) continue;
        int y;
        std::frexp(m,&y);
        if (e[i] + y >= small) { s[i] = std::ldexp(m,e[i]); s1[i] = std::ldexp(m2[i],e[i]); e[i] = 0; }
        else if (y > 256) { m1[i] = std::ldexp(m,-256); m2[i] = std::ldexp(m2[i],-256); e[i] += 256; }
      }
      for (int a = std::max(l0,h0+1); a < L; a++)
        s[o+a] = (v * p[a]) * s1[o+a] + (w * q[a]) * s2[o+a];
      while (lo[b] <= hi[b] && e[o+lo[b]] == 0) lo[b]++;
      while (hi[b] >= lo[b] && e[o+hi[b]] == 0) hi[b]--;
    }
  }
};
