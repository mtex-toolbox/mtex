/* latticeVoronoi_mex.c - the Voronoi cells of sites on the slots of a lattice raster
 *
 *   [V,F,I_FD] = latticeVoronoi_mex(XY,slot,szP,A,numReal,epsilon,alpha)
 *
 * The compiled form of latticeVoronoi.m, see there for the arguments. The cell
 * of a site is a box around it clipped against the bisectors of the sites on
 * the lattice slots around it, nearest first, until the next one is further
 * than twice the radius of the cell; a cell still open is computed again with
 * a reach 4 and 16 times as large. Every face is taken from its lower site and
 * its end points are welded within epsilon as they come.
 *
 *   mex -R2018a latticeVoronoi_mex.c
 */
#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define JCVX_NO_JC_VORONOI
typedef double jcv_real;
typedef struct { jcv_real x, y; } jcv_point;
#include "../../../extern/jcvoronoi/jc_voronoi_ext.h"

#define K 256

/* a lattice offset, its ideal length, and its place in ndgrid order for the ties */
typedef struct { long di, dj, ord; double d; } offset;

static int cmpOffset(const void *a, const void *b) {
  const offset *p = (const offset *)a, *q = (const offset *)b;
  if (p->d != q->d) return p->d < q->d ? -1 : 1;
  return (p->ord > q->ord) - (p->ord < q->ord);
}

/* the offsets within k steps, nearest first */
static offset *offsetsOf(long k, const double *A, long *n) {
  long w = 2 * k + 1, c = 0;
  offset *o = (offset *)mxMalloc(sizeof(offset) * (size_t)(w * w));
  for (long jj = 0; jj < w; jj++)
    for (long ii = 0; ii < w; ii++) {
      long di = ii - k, dj = jj - k;
      if (!di && !dj) continue;
      double x = A[0] * di + A[2] * dj, y = A[1] * di + A[3] * dj;
      o[c].di = di; o[c].dj = dj; o[c].ord = c; o[c].d = sqrt(x * x + y * y); c++;
    }
  qsort(o, (size_t)c, sizeof(offset), cmpOffset);
  *n = c;
  return o;
}

/* the polygon vs of m vertices cut by the half plane n.v <= |n|^2/2, edge i running
 * from vertex i to i+1 along the bisector with site gs[i]; returns the new count */
static int clip(double *vs, int *gs, int m, double nx, double ny, int gen) {
  double ws[2 * K], d[K], h = (nx * nx + ny * ny) / 2;
  int hs[K], c = 0, cut = 0;
  for (int i = 0; i < m; i++) {
    d[i] = nx * vs[2 * i] + ny * vs[2 * i + 1] - h;
    cut |= d[i] > 0;
  }
  if (!cut) return m;
  for (int i = 0; i < m; i++) {
    int i2 = i + 1 < m ? i + 1 : 0;
    double d1 = d[i], d2 = d[i2], t = d1 / (d1 - d2);
    double ix = vs[2 * i] + t * (vs[2 * i2] - vs[2 * i]), iy = vs[2 * i + 1] + t * (vs[2 * i2 + 1] - vs[2 * i + 1]);
    if (c + 2 > K) mexErrMsgIdAndTxt("latticeVoronoi:cell", "a cell has more than %d vertices", K);
    /* a vertex inside emits itself and the crossing if its edge leaves, one outside the crossing if its edge enters */
    if (d1 <= 0) {
      ws[2 * c] = vs[2 * i]; ws[2 * c + 1] = vs[2 * i + 1]; hs[c++] = gs[i];
      if (d2 > 0) { ws[2 * c] = ix; ws[2 * c + 1] = iy; hs[c++] = gen; }
    } else if (d2 <= 0) {
      ws[2 * c] = ix; ws[2 * c + 1] = iy; hs[c++] = gs[i];
    }
  }
  memcpy(vs, ws, sizeof(double) * 2 * (size_t)c);
  memcpy(gs, hs, sizeof(int) * (size_t)c);
  return c;
}

/* the cell of the site at (px,py) on slot (r0,c0), relative to it, from a box of half
 * width W clipped by the sites of the offsets o; *open says whether a box edge survived */
static int cellOf(double *vs, int *gs, double px, double py, long r0, long c0, const double *XY,
                  long nS, const int *lookup, long n1, long n2, const offset *o, long no,
                  double W, int *open) {
  int m = 4;
  double rad2 = 2 * W * W;
  vs[0] = -W; vs[1] = -W; vs[2] = W; vs[3] = -W; vs[4] = W; vs[5] = W; vs[6] = -W; vs[7] = W;
  gs[0] = gs[1] = gs[2] = gs[3] = 0;
  *open = 1;
  for (long j = 0; j < no; j++) {
    /* a closed cell cannot be cut by a site further than twice its radius */
    if (!*open && 0.9025 * o[j].d * o[j].d > 4 * rad2) break;
    long r = r0 + o[j].di, c = c0 + o[j].dj;
    if (r < 0 || r >= n1 || c < 0 || c >= n2) continue;
    int q = lookup[r + c * n1];
    if (q < 0) continue;
    m = clip(vs, gs, m, XY[q] - px, XY[nS + q] - py, q + 1);
    rad2 = 0; *open = 0;
    for (int i = 0; i < m; i++) {
      double r2 = vs[2 * i] * vs[2 * i] + vs[2 * i + 1] * vs[2 * i + 1];
      if (r2 > rad2) rad2 = r2;
      if (!gs[i]) *open = 1;
    }
  }
  return m;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  if (nrhs != 7) mexErrMsgIdAndTxt("latticeVoronoi:args", "expected XY,slot,szP,A,numReal,epsilon,alpha");
  for (int i = 0; i < 7; i++)
    if (!mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) || mxIsSparse(prhs[i]))
      mexErrMsgIdAndTxt("latticeVoronoi:args", "every argument must be a real double");
  const double *XY = mxGetDoubles(prhs[0]), *slot = mxGetDoubles(prhs[1]);
  const double *szP = mxGetDoubles(prhs[2]), *A = mxGetDoubles(prhs[3]);
  long nS = (long)mxGetM(prhs[0]), numReal = (long)mxGetScalar(prhs[4]);
  double epsilon = mxGetScalar(prhs[5]), alpha = mxGetScalar(prhs[6]);
  long n1 = (long)szP[0], n2 = (long)szP[1];
  if (mxGetN(prhs[0]) != 2 || (long)mxGetNumberOfElements(prhs[1]) != nS || numReal > nS)
    mexErrMsgIdAndTxt("latticeVoronoi:args", "XY must be nS x 2, slot nS long, numReal at most nS");

  /* the site on every slot */
  int *lookup = (int *)mxMalloc(sizeof(int) * (size_t)(n1 * n2));
  for (long l = 0; l < n1 * n2; l++) lookup[l] = -1;
  for (long s = 0; s < nS; s++) {
    long l = (long)slot[s] - 1;
    if (l < 0 || l >= n1 * n2) mexErrMsgIdAndTxt("latticeVoronoi:args", "slot outside the raster");
    lookup[l] = (int)s;
  }

  /* the weld runs on coordinates about the centre of the sites */
  double x0 = XY[0], x1 = XY[0], y0 = XY[nS], y1 = XY[nS];
  for (long s = 0; s < nS; s++) {
    x0 = fmin(x0, XY[s]); x1 = fmax(x1, XY[s]); y0 = fmin(y0, XY[nS + s]); y1 = fmax(y1, XY[nS + s]);
  }
  double cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
  if (fmax(x1 - cx, y1 - cy) / epsilon > 2.0e9)
    mexErrMsgIdAndTxt("latticeVoronoi:eps", "epsilon is too small for the extent of the map");

  double dxy = (sqrt(A[0] * A[0] + A[1] * A[1]) + sqrt(A[2] * A[2] + A[3] * A[3])) / 2;
  long kmax = (long)ceil(2 * alpha) + 2, no[3] = {0, 0, 0};
  offset *o[3] = {NULL, NULL, NULL};
  o[0] = offsetsOf(kmax, A, &no[0]);

  jcvx_welder w;
  jcvx_welder_init(&w, (int)(2 * numReal), epsilon);
  long cap = 4 * numReal + 16, nF = 0;
  int *fa = (int *)mxMalloc(sizeof(int) * (size_t)cap), *fb = (int *)mxMalloc(sizeof(int) * (size_t)cap);
  int *fs = (int *)mxMalloc(sizeof(int) * (size_t)cap), *fq = (int *)mxMalloc(sizeof(int) * (size_t)cap);

  double vs[2 * K];
  int gs[K];
  for (long s = 0; s < numReal; s++) {
    double px = XY[s], py = XY[nS + s];
    long r0 = ((long)slot[s] - 1) % n1, c0 = ((long)slot[s] - 1) / n1;
    int m = 0, open = 1;
    for (int lv = 0; lv < 3 && open; lv++) {
      long k = kmax << (2 * lv);
      if (!o[lv]) o[lv] = offsetsOf(k, A, &no[lv]);
      m = cellOf(vs, gs, px, py, r0, c0, XY, nS, lookup, n1, n2, o[lv], no[lv], 1.5 * k * dxy, &open);
    }
    if (open) mexErrMsgIdAndTxt("latticeVoronoi:open", "the cell of site %ld reaches beyond 16 times the closing", s + 1);

    /* the faces towards sites of higher index, welded */
    for (int i = 0; i < m; i++) {
      int g = gs[i] - 1, i2 = i + 1 < m ? i + 1 : 0;
      if (g <= s) continue;
      int a = jcvx_welder_add(&w, px + vs[2 * i] - cx, py + vs[2 * i + 1] - cy);
      int b = jcvx_welder_add(&w, px + vs[2 * i2] - cx, py + vs[2 * i2 + 1] - cy);
      double dx = w.px[a] - w.px[b], dy = w.py[a] - w.py[b];
      if (a == b || dx * dx + dy * dy <= epsilon * epsilon) continue;
      if (nF == cap) {
        cap *= 2;
        fa = (int *)mxRealloc(fa, sizeof(int) * (size_t)cap); fb = (int *)mxRealloc(fb, sizeof(int) * (size_t)cap);
        fs = (int *)mxRealloc(fs, sizeof(int) * (size_t)cap); fq = (int *)mxRealloc(fq, sizeof(int) * (size_t)cap);
      }
      fa[nF] = a < b ? a : b; fb[nF] = a < b ? b : a; fs[nF] = (int)s; fq[nF] = g; nF++;
    }
  }

  /* V and F */
  plhs[0] = mxCreateDoubleMatrix((size_t)w.n, 2, mxREAL);
  double *V = mxGetDoubles(plhs[0]);
  for (int j = 0; j < w.n; j++) { V[j] = w.px[j] + cx; V[w.n + j] = w.py[j] + cy; }
  jcvx_welder_free(&w);
  plhs[1] = mxCreateDoubleMatrix((size_t)nF, 2, mxREAL);
  double *F = mxGetDoubles(plhs[1]);
  for (long f = 0; f < nF; f++) { F[f] = fa[f] + 1; F[nF + f] = fb[f] + 1; }

  /* I_FD column by column, the rows of a column ascending as the faces came */
  mwIndex *jc = (mwIndex *)mxCalloc((size_t)numReal + 1, sizeof(mwIndex));
  for (long f = 0; f < nF; f++) { jc[fs[f] + 1]++; if (fq[f] < numReal) jc[fq[f] + 1]++; }
  for (long s = 0; s < numReal; s++) jc[s + 1] += jc[s];
  plhs[2] = mxCreateSparse((size_t)nF, (size_t)numReal, jc[numReal] > 0 ? jc[numReal] : 1, mxREAL);
  double *pr = mxGetDoubles(plhs[2]);
  mwIndex *ir = mxGetIr(plhs[2]), *pjc = mxGetJc(plhs[2]);
  memcpy(pjc, jc, sizeof(mwIndex) * ((size_t)numReal + 1));
  for (long f = 0; f < nF; f++) {
    ir[jc[fs[f]]] = (mwIndex)f; pr[jc[fs[f]]++] = 1;
    if (fq[f] < numReal) { ir[jc[fq[f]]] = (mwIndex)f; pr[jc[fq[f]]++] = 1; }
  }

  mxFree(jc); mxFree(lookup); mxFree(fa); mxFree(fb); mxFree(fs); mxFree(fq);
  for (int lv = 0; lv < 3; lv++) if (o[lv]) mxFree(o[lv]);
  (void)nlhs;
}
