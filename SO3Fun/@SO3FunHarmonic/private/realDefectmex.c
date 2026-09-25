/*=========================================================================
 * realDefectmex.c - how far Wigner coefficients are from a real function
 *
 * The coefficients of a real valued function satisfy
 *   fhat(n,k,l) = conj(fhat(n,-k,-l)).
 * For every column this returns in one pass
 *   r(1) = sum |fhat(n,k,l) - conj(fhat(n,-k,-l))|^2,   r(2) = sum |fhat(n,k,l)|^2
 * over the degrees 0..N, where fhat(n,-k,-l) is the reversed entry of the
 * (2n+1) x (2n+1) block of degree n.
 *
 * Syntax
 *   r = realDefectmex(fhat)
 *
 * Input
 *  fhat - Wigner coefficients of the degrees 0..N, one column per function
 *
 * Output
 *  r - 2 x number of columns
 *
 * This is a MEX-file for MATLAB.
 *=======================================================================*/

#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nrhs != 1 || nlhs > 1 || !mxIsDouble(prhs[0]) || mxIsSparse(prhs[0]))
    mexErrMsgIdAndTxt("realDefectmex:args","r = realDefectmex(fhat) with full double fhat.");

  const size_t M = mxGetM(prhs[0]), nFun = mxGetN(prhs[0]);
  int L = 0;
  while ((size_t)(L+1)*(2*L+1)*(2*L+3)/3 < M) L++;
  if ((size_t)(L+1)*(2*L+1)*(2*L+3)/3 != M)
    mexErrMsgIdAndTxt("realDefectmex:size","The number of rows is not that of the degrees 0..N.");

  const int cplx = mxIsComplex(prhs[0]);
  const mxComplexDouble *fc = cplx ? mxGetComplexDoubles(prhs[0]) : NULL;
  const double *fr = cplx ? NULL : mxGetDoubles(prhs[0]);

  plhs[0] = mxCreateDoubleMatrix(2,nFun,mxREAL);
  double *r = mxGetDoubles(plhs[0]);

  for (size_t m = 0; m < nFun; m++)
  {
    double dd = 0, nn = 0;
    size_t o = m*M;
    for (int n = 0; n <= L; n++)
    {
      const size_t w2 = (size_t)(2*n+1)*(2*n+1);
      for (size_t i = 0; i < w2; i++)
      {
        const size_t p = o + w2-1-i;
        const double ar = cplx ? fc[o+i].real : fr[o+i], ai = cplx ? fc[o+i].imag : 0;
        const double br = cplx ? fc[p].real : fr[p], bi = cplx ? fc[p].imag : 0;
        dd += (ar-br)*(ar-br) + (ai+bi)*(ai+bi);
        nn += ar*ar + ai*ai;
      }
      o += w2;
    }
    r[2*m] = dd; r[2*m+1] = nn;
  }
}
