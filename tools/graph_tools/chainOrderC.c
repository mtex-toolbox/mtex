/*
 * chainOrderC - decompose an undirected edge list into maximal chains
 *
 *   [cid,pos,firstEnd] = chainOrderC(F,nV)
 *
 * A chain is a maximal run of edges joined at vertices of degree two; a
 * vertex of any other degree is a junction and terminates a chain. Each
 * chain is walked from one end to the other, which is what gives every edge
 * a position within its chain and tells which of its two vertices the walk
 * enters it at.
 *
 * The whole computation is a sequence of O(1) pointer hops per half edge,
 * which is why it is worth doing in C: the MATLAB formulation has to fake
 * the sequential walk with pointer doubling over the full half edge array
 * plus a sparse connected-components pass.
 *
 * Input
 *  F  - nF x 2 double, one-based vertex indices
 *  nV - number of vertices
 *
 * Output
 *  cid      - nF x 1, chain id, 1..nCh
 *  pos      - nF x 1, zero-based position of the edge within its chain
 *  firstEnd - nF x 1, 1 or 2 - the column of F holding the entry vertex
 *
 * Conventions - these reproduce the MATLAB reference implementation in
 * chainOrder.m exactly, so that both paths return the same permutation:
 *
 *  - a chain is walked from its lower terminal half edge, where half edges
 *    are ordered as MATLAB indexes them, h = k + e*nF ("edge k entered at
 *    vertex F(k,e+1)", zero based)
 *  - a closed chain has no terminal, so it is cut at its lowest vertex
 *  - chains are numbered by increasing highest member edge index, which is
 *    what etree - and hence connectedComponents - assigns
 *
 * The walk itself is pointer chasing over an edge list in arbitrary order,
 * so it is bound by cache misses rather than arithmetic. Two layout choices
 * follow from that and are the reason for the local half edge numbering
 * hh = 2*k+e used below, which is NOT the MATLAB one:
 *
 *  - the two half edges of an edge sit next to each other in partner[], so
 *    stepping through an edge stays inside one cache line
 *  - chain id, position and entry end are interleaved into one record per
 *    edge in res[], so the walk writes one cache line per edge instead of
 *    three, with res[3*k] = -1 doubling as the "not yet visited" mark
 */

#include "mex.h"
#include <stddef.h>
#include <string.h>

typedef ptrdiff_t idx_t;

/* local half edge numbering, interleaved by edge */
#define HH(k,e)  (2*(k) + (e))
#define HH_K(hh) ((hh) >> 1)
#define HH_E(hh) ((hh) & 1)

/* the MATLAB half edge numbering, used only where a tie has to be broken
 * the same way the reference implementation breaks it */
#define ML_H(k,e) ((k) + (e)*nF)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const double *F;
  double *cidOut, *posOut, *endOut;
  idx_t nF, nH, nV, nCh, h, v, e, k, k0, p, i, c, lab;
  idx_t *off, *fill;
  int *hs, *partner, *res, *maxSeg, *chainAtMax, *newLab;

  if (nrhs != 2)
    mexErrMsgIdAndTxt("MTEX:chainOrderC:nrhs","two inputs required: F, nV");
  if (nlhs > 3)
    mexErrMsgIdAndTxt("MTEX:chainOrderC:nlhs","at most three outputs");
  if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetN(prhs[0]) != 2)
    mexErrMsgIdAndTxt("MTEX:chainOrderC:F","F must be a real nF x 2 double matrix");
  if (!mxIsDouble(prhs[1]) || mxGetNumberOfElements(prhs[1]) != 1)
    mexErrMsgIdAndTxt("MTEX:chainOrderC:nV","nV must be a scalar double");

  F  = mxGetDoubles(prhs[0]);
  nF = (idx_t) mxGetM(prhs[0]);
  nV = (idx_t) mxGetScalar(prhs[1]);
  nH = 2*nF;

  plhs[0] = mxCreateDoubleMatrix((mwSize)nF,1,mxREAL);
  plhs[1] = mxCreateDoubleMatrix((mwSize)nF,1,mxREAL);
  plhs[2] = mxCreateDoubleMatrix((mwSize)nF,1,mxREAL);
  if (nF == 0) return;

  /* half edge ids are stored in int, so 2*nF has to fit */
  if (nF > 1073741823)
    mexErrMsgIdAndTxt("MTEX:chainOrderC:size","too many edges for chainOrderC");

  cidOut = mxGetDoubles(plhs[0]);
  posOut = mxGetDoubles(plhs[1]);
  endOut = mxGetDoubles(plhs[2]);

  /* -- group the half edges by vertex ------------------------------------
   * off[v]..off[v+1]-1 is the block of hs belonging to vertex v. The fill
   * loop runs over e first and then over k, i.e. in increasing MATLAB half
   * edge id, so hs[off[v]] is the lower of the two half edges meeting at a
   * degree two vertex - the tie break the cut of a closed chain needs */
  off = (idx_t*) mxCalloc((size_t)(nV+2), sizeof(idx_t));
  for (h = 0; h < nH; h++) {
    v = (idx_t) F[h];
    if (v < 1 || v > nV)
      mexErrMsgIdAndTxt("MTEX:chainOrderC:vertex","F contains a vertex index outside 1..nV");
    off[v+1]++;
  }
  for (v = 1; v <= nV; v++) off[v+1] += off[v];

  fill = (idx_t*) mxMalloc((size_t)(nV+2)*sizeof(idx_t));
  memcpy(fill,off,(size_t)(nV+2)*sizeof(idx_t));

  hs = (int*) mxMalloc((size_t)nH*sizeof(int));
  for (e = 0; e < 2; e++)
    for (k = 0; k < nF; k++) {
      v = (idx_t) F[k + e*nF];
      hs[fill[v]++] = (int) HH(k,e);
    }

  /* -- pair up the two half edges meeting at every degree two vertex ----- */
  partner = (int*) mxMalloc((size_t)nH*sizeof(int));
  for (h = 0; h < nH; h++) partner[h] = -1;
  for (v = 1; v <= nV; v++) {
    if (off[v+1] - off[v] == 2) {
      int a = hs[off[v]], b = hs[off[v]+1];
      partner[a] = b;
      partner[b] = a;
    }
  }

  /* one record per edge: chain id, position, entry end */
  res = (int*) mxMalloc((size_t)(3*nF)*sizeof(int));
  memset(res,0xFF,(size_t)(3*nF)*sizeof(int));   /* res[3k] = -1: unvisited */

  maxSeg = (int*) mxMalloc((size_t)nF*sizeof(int));

  nCh = 0;
  for (k0 = 0; k0 < nF; k0++) {

    idx_t startK, startE, len, steps, kMax;
    int closed = 0;

    if (res[3*k0] >= 0) continue;

    /* -- walk backwards to the head of the chain -------------------------
     * stepping back from edge k entered at end e means crossing to the
     * partner at F(k,e+1); that edge leaves through the shared vertex, so
     * it was entered at its other end */
    k = k0; e = 0; steps = 0;
    while (1) {
      p = partner[HH(k,e)];
      if (p < 0) break;
      {
        idx_t k2 = HH_K(p), e2 = 1 - HH_E(p);
        if (k2 == k0 && e2 == 0) { closed = 1; break; }
        k = k2; e = e2;
      }
      if (++steps > nF) { closed = 1; break; }
    }

    if (closed) {

      /* a closed chain has no terminal half edge, so cut it at its lowest
       * vertex - the same rule the MATLAB path uses, so that both agree on
       * where the loop starts */
      idx_t vmin = -1, kk = k0, ee = 0;
      int a, b;
      steps = 0;
      while (1) {
        idx_t v1 = (idx_t) F[kk], v2 = (idx_t) F[kk+nF];
        if (vmin < 0 || v1 < vmin) vmin = v1;
        if (v2 < vmin) vmin = v2;
        p = partner[HH(kk,1-ee)];
        if (p < 0) break;
        kk = HH_K(p); ee = HH_E(p);
        if (kk == k0 && ee == 0) break;
        if (++steps > nF) break;
      }
      a = hs[off[vmin]];
      b = hs[off[vmin]+1];
      partner[a] = -1;
      partner[b] = -1;
      startK = HH_K(a); startE = HH_E(a);

    } else {
      startK = k; startE = e;
    }

    /* -- walk the chain from head to tail -------------------------------- */
    len = 0; kMax = startK;
    k = startK; e = startE;
    while (1) {
      res[3*k]   = (int) nCh;
      res[3*k+1] = (int) len;
      res[3*k+2] = (int)(e + 1);
      if (k > kMax) kMax = k;
      len++;
      p = partner[HH(k,1-e)];
      if (p < 0) break;
      k = HH_K(p); e = HH_E(p);
      if (len > nF) break;
    }

    /* -- of the two directions take the one starting at the lower MATLAB
     * half edge; k,e is the tail, so its reverse entry is (k,1-e) --------- */
    if (!closed && ML_H(k,1-e) < ML_H(startK,startE)) {
      idx_t kk = k, ee = 1-e, ll = 0;
      while (1) {
        res[3*kk+1] = (int) ll;
        res[3*kk+2] = (int)(ee + 1);
        ll++;
        p = partner[HH(kk,1-ee)];
        if (p < 0) break;
        kk = HH_K(p); ee = HH_E(p);
        if (ll > nF) break;
      }
    }

    maxSeg[nCh] = (int) kMax;
    nCh++;
  }

  /* -- number the chains by increasing highest member edge ---------------
   * connectedComponents labels a component by its etree root, which is its
   * highest numbered node, and hands out labels in increasing root order */
  chainAtMax = (int*) mxMalloc((size_t)nF*sizeof(int));
  memset(chainAtMax,0xFF,(size_t)nF*sizeof(int));
  for (c = 0; c < nCh; c++) chainAtMax[maxSeg[c]] = (int) c;

  newLab = (int*) mxMalloc((size_t)(nCh > 0 ? nCh : 1)*sizeof(int));
  lab = 0;
  for (i = 0; i < nF; i++)
    if (chainAtMax[i] >= 0) newLab[chainAtMax[i]] = (int) lab++;

  for (k = 0; k < nF; k++) {
    cidOut[k] = (double)(newLab[res[3*k]] + 1);
    posOut[k] = (double) res[3*k+1];
    endOut[k] = (double) res[3*k+2];
  }
}
