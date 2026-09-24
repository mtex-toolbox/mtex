/*=========================================================================
 * symmetriseWignermex.c - projection of Wigner coefficients onto the
 * functions that are symmetric w.r.t. a right and a left symmetry
 *
 * For every degree n the (2n+1) x (2n+1) block of the Wigner coefficients
 * is multiplied as
 *
 *   fhat_n  ->  C_n * fhat_n * S_n / (2n+1)
 *
 * with the blocks C_n, S_n of the sparse vectors C = CS.WignerD and
 * S = SS.WignerD, which is convSO3(convSO3(fhat,C),S) - only the nonzero
 * entries of C_n and S_n are visited. An empty C or S is the identity and
 * drops the factor sqrt(2n+1) of its side.
 *
 * Syntax
 *   fhat = symmetriseWignermex(N,fhat,C,S)
 *
 * Input
 *  N    - bandwidth
 *  fhat - Wigner coefficients up to degree N or more, one column per function
 *  C, S - sparse Wigner coefficients of the projections up to degree N or more, or []
 *
 * Output
 *  fhat - projected Wigner coefficients up to degree N
 *
 * This is a MEX-file for MATLAB.
 *=======================================================================*/

#include <mex.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#ifdef _OPENMP
#include <omp.h>
#endif

// the nonzero entries (row r, column c, value v) of the degree blocks of a
// sparse vector, those of degree n at start[n] .. start[n+1]-1
typedef struct { int *r, *c; mxComplexDouble *v; mwSize *start; } blocks;

static int deg2dim(int n) { return n*(2*n-1)*(2*n+1)/3; }

static blocks read_blocks(const mxArray *A, int N)
{
  blocks B = {NULL,NULL,NULL,NULL};
  if (mxIsEmpty(A)) return B;
  if (!mxIsSparse(A) || mxGetN(A) != 1 || mxGetM(A) < (size_t)deg2dim(N+1))
    mexErrMsgIdAndTxt("symmetriseWignermex:notSparse","The projections must be sparse column vectors up to the bandwidth.");

  const mwIndex *ir = mxGetIr(A);
  const mwSize nz = mxGetJc(A)[1];
  const int cplx = mxIsComplex(A);
  const mxComplexDouble *cv = cplx ? mxGetComplexDoubles(A) : NULL;
  const double *rv = cplx ? NULL : mxGetDoubles(A);

  B.r = mxMalloc(nz*sizeof(int)); B.c = mxMalloc(nz*sizeof(int));
  B.v = mxMalloc(nz*sizeof(mxComplexDouble)); B.start = mxCalloc(N+2,sizeof(mwSize));
  mwSize i = 0;
  for (int n = 0; n <= N; n++)
  {
    const mwIndex d0 = deg2dim(n), d1 = deg2dim(n+1), w = 2*n+1;
    B.start[n] = i;
    for (; i < nz && ir[i] < d1; i++)
    {
      B.r[i] = (ir[i]-d0) % w; B.c[i] = (ir[i]-d0) / w;
      if (cplx) B.v[i] = cv[i]; else { B.v[i].real = rv[i]; B.v[i].imag = 0; }
    }
  }
  B.start[N+1] = i;
  return B;
}

// out = C * F * S / (2n+1) of one degree block, T is a buffer of w*w entries
static void project_block(const int n, const mxComplexDouble *F, const blocks C, const blocks S,
                          mxComplexDouble *T, mxComplexDouble *out)
{
  const int w = 2*n+1;
  const double sc = (C.v ? 1/sqrt(w) : 1) * (S.v ? 1/sqrt(w) : 1);

  // T = F * S, its column c gathers the columns r of F
  const mxComplexDouble *G = F;
  if (S.v)
  {
    memset(T,0,(size_t)w*w*sizeof(mxComplexDouble));
    for (mwSize i = S.start[n]; i < S.start[n+1]; i++)
    {
      const mxComplexDouble v = S.v[i];
      const mxComplexDouble *f = F + (size_t)S.r[i]*w;
      mxComplexDouble *t = T + (size_t)S.c[i]*w;
      for (int k = 0; k < w; k++)
      {
        t[k].real += f[k].real*v.real - f[k].imag*v.imag;
        t[k].imag += f[k].real*v.imag + f[k].imag*v.real;
      }
    }
    G = T;
  }

  // out = C * G, its row r gathers the rows c of G
  if (C.v)
    for (mwSize i = C.start[n]; i < C.start[n+1]; i++)
    {
      const mxComplexDouble v = C.v[i];
      const mxComplexDouble *g = G + C.c[i];
      mxComplexDouble *o = out + C.r[i];
      for (int j = 0; j < w; j++)
      {
        const mxComplexDouble x = g[(size_t)j*w];
        o[(size_t)j*w].real += sc*(x.real*v.real - x.imag*v.imag);
        o[(size_t)j*w].imag += sc*(x.real*v.imag + x.imag*v.real);
      }
    }
  else
    for (size_t k = 0; k < (size_t)w*w; k++)
    {
      out[k].real = sc*G[k].real;
      out[k].imag = sc*G[k].imag;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nrhs != 4 || nlhs != 1)
    mexErrMsgIdAndTxt("symmetriseWignermex:args","fhat = symmetriseWignermex(N,fhat,C,S)");
  const double bw = mxGetScalar(prhs[0]);
  if (bw < 0 || bw != floor(bw))
    mexErrMsgIdAndTxt("symmetriseWignermex:notInt","The bandwidth must be a natural number.");
  const int N = bw;
  if (!mxIsDouble(prhs[1]) || mxIsSparse(prhs[1]) || mxGetM(prhs[1]) < (size_t)deg2dim(N+1))
    mexErrMsgIdAndTxt("symmetriseWignermex:notDouble","fhat must be full double coefficients up to the bandwidth.");

  // real coefficients are read as complex ones
  mxArray *copy = NULL;
  const mxArray *X = prhs[1];
  if (!mxIsComplex(X)) { copy = mxDuplicateArray(X); mxMakeArrayComplex(copy); X = copy; }
  const mxComplexDouble *fhat = mxGetComplexDoubles(X);
  const size_t ldf = mxGetM(prhs[1]), nFun = mxGetN(prhs[1]), ldo = deg2dim(N+1);

  const blocks C = read_blocks(prhs[2],N), S = read_blocks(prhs[3],N);

  plhs[0] = mxCreateDoubleMatrix(ldo,nFun,mxCOMPLEX);
  mxComplexDouble *out = mxGetComplexDoubles(plhs[0]);

  #pragma omp parallel if(N >= 16)
  {
    mxComplexDouble *T = malloc((size_t)(2*N+1)*(2*N+1)*sizeof(mxComplexDouble));
    #pragma omp for schedule(dynamic) collapse(2)
    for (size_t m = 0; m < nFun; m++)
      for (int n = N; n >= 0; n--)
        project_block(n,fhat + m*ldf + deg2dim(n),C,S,T,out + m*ldo + deg2dim(n));
    free(T);
  }

  // a result without imaginary part is real, as in MATLAB arithmetic
  size_t k = 0;
  while (k < ldo*nFun && out[k].imag == 0) k++;
  if (k == ldo*nFun) mxMakeArrayReal(plhs[0]);
  if (copy) mxDestroyArray(copy);
}
