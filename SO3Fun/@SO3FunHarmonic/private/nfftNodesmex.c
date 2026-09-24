/*=========================================================================
 * nfftNodesmex.c - nfft nodes of rotations or directions
 *
 *   [x,bad,phase] = nfftNodesmex(a,b,c,d,r,s)
 *   [x,bad,phase] = nfftNodesmex(vx,vy,vz,s)
 *
 * Rotations with quaternion components a,b,c,d give the 3 x M nodes
 * [alpha;beta;gamma]/(2 pi) of the Euler angles in the nfft (ZYZ)
 * convention. The rows 1 and 3 are folded by the Z-axis symmetries r(1) and
 * r(2): x -> mod(r x + 1/2,1) - 1/2 if r > 1. The optional phase is
 * exp(2 pi i (s(1) x(1,:) + s(2) x(3,:))) of the folded nodes.
 *
 * Directions vx,vy,vz give the 2 x M nodes [theta;rho]/(2 pi) of the polar
 * angles and the optional phase exp(2 pi i s x(2,:)).
 *
 * Non finite input gives the node 0 and bad = true.
 *=========================================================================*/

#include <math.h>
#include "mex.h"

#ifdef _OPENMP
#include <omp.h>
#endif

#define TWO_PI 6.283185307179586476925286766559

/* x in [0,1) folded by r to [-1/2,1/2) */
static inline double fold(double x, double r)
{
  if (r <= 1) return x;
  x = r * x + 0.5;
  return x - floor(x) - 0.5;
}

/* a in [0,1) */
static inline double frac(double a) { return a - floor(a); }

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const int so3 = nrhs >= 5;
  const int d = so3 ? 3 : 2, nin = so3 ? 4 : 3;
  const mwSize M = nrhs >= 3 ? mxGetNumberOfElements(prhs[0]) : 0;
  const double *in[4];
  double r[2] = {1, 1}, s[2] = {0, 0};
  int k;

  if (nrhs < 3 || nrhs > 6)
    mexErrMsgTxt("nfftNodesmex(a,b,c,d,r,[s]) or nfftNodesmex(vx,vy,vz,[s])");
  for (k = 0; k < nin; k++)
  {
    if (!mxIsDouble(prhs[k]) || mxIsComplex(prhs[k]) || mxGetNumberOfElements(prhs[k]) != M)
      mexErrMsgTxt("nfftNodesmex: the components must be real double arrays of equal size");
    in[k] = mxGetDoubles(prhs[k]);
  }
  if (so3)
    for (k = 0; k < 2 && k < (int)mxGetNumberOfElements(prhs[4]); k++)
      r[k] = mxGetDoubles(prhs[4])[k];
  const int hasS = nrhs > nin + so3;
  if (hasS)
    for (k = 0; k < d - 1 && k < (int)mxGetNumberOfElements(prhs[nin + so3]); k++)
      s[k] = mxGetDoubles(prhs[nin + so3])[k];

  plhs[0] = mxCreateDoubleMatrix(d, M, mxREAL);
  double *x = mxGetDoubles(plhs[0]);
  mxComplexDouble *ph = NULL;
  mxLogical *bad = NULL;
  if (nlhs > 1)
  {
    plhs[1] = mxCreateLogicalMatrix(M, 1);
    bad = mxGetLogicals(plhs[1]);
  }
  if (nlhs > 2)
  {
    if (!hasS) mexErrMsgTxt("nfftNodesmex: the phase needs the shifts s");
    plhs[2] = mxCreateDoubleMatrix(M, 1, mxCOMPLEX);
    ph = mxGetComplexDoubles(plhs[2]);
  }

  #pragma omp parallel for schedule(static)
  for (mwSize j = 0; j < M; j++)
  {
    double *xj = x + d * j, p;
    int ok = 1, t;
    if (so3)
    {
      const double qa = in[0][j], qb = in[1][j], qc = in[2][j], qd = in[3][j];
      const double at1 = atan2(qd, qa), at2 = atan2(qb, qc);
      xj[0] = fold(frac((at1 - at2) / TWO_PI), r[0]);
      xj[1] = atan2(sqrt(qb * qb + qc * qc), sqrt(qa * qa + qd * qd)) * (2 / TWO_PI);
      xj[2] = fold(frac((at1 + at2) / TWO_PI), r[1]);
      p = s[0] * xj[0] + s[1] * xj[2];
    }
    else
    {
      const double vx = in[0][j], vy = in[1][j], vz = in[2][j];
      const double nv = sqrt(vx * vx + vy * vy + vz * vz);
      xj[0] = acos(fmax(-1.0, fmin(1.0, vz / nv))) / TWO_PI;
      xj[1] = frac(atan2(vy, vx) / TWO_PI);
      p = s[0] * xj[1];
    }
    for (t = 0; t < d; t++)
      ok &= isfinite(xj[t]) != 0;
    if (!ok)
      for (t = 0; t < d; t++) xj[t] = 0;
    if (ph)
    {
      ph[j].real = ok ? cos(TWO_PI * p) : NAN;
      ph[j].imag = ok ? sin(TWO_PI * p) : NAN;
    }
    if (bad) bad[j] = !ok;
  }
}
