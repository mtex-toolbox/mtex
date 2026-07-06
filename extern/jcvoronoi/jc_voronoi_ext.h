/* jc_voronoi_ext.h -- MTEX extensions to jc_voronoi
 *
 * Provides
 *
 *   jcvx_welder            hash-grid based point welding with tolerance eps:
 *                          points closer than eps are identified. Used for
 *                          (a) input site deduplication and (b) welding of
 *                          numerically duplicated Voronoi vertices /
 *                          collapsing of edges shorter than eps.
 *
 *   jcvx_dedup_points      tolerance based deduplication of an input point
 *                          set, reporting a map original -> unique index
 *
 *   jcvx_diagram_generate  drop-in replacement for jcv_diagram_generate that
 *                          removes duplicate sites (within eps) *before*
 *                          construction and reports the site map. The body of
 *                          jcvx_dedup_points can later be moved verbatim into
 *                          jcv_diagram_generate (replacing its internal
 *                          exact-duplicate skip) once we diff against the
 *                          vendored jc_voronoi.h version.
 *
 * Include AFTER jc_voronoi.h (needs jcv_real / jcv_point).
 * Define JCVX_NO_JC_VORONOI to use welder/dedup standalone (unit testing).
 *
 * Plain C99, no dependencies beyond libc, everything static (header only).
 *
 * NOTE quantization range: cell indices are computed as llround(x/eps) and
 * packed into 32 bit each. The caller must guarantee |x|/eps < 2^31, i.e.
 * center the coordinates and choose eps not absurdly small relative to the
 * map extent (the MEX checks this).
 */

#ifndef JC_VORONOI_EXT_H
#define JC_VORONOI_EXT_H

#include <stdlib.h>
#include <string.h>
#include <math.h>

/* ------------------------------------------------------------------ */
/* welder: spatial hash on cells of size eps, probing the 3x3 cell     */
/* neighborhood; two points within eps always land in neighboring      */
/* cells, so the probe is exhaustive.                                  */
/* ------------------------------------------------------------------ */

typedef struct jcvx_welder {
    jcv_real   inv_eps;   /* 1/eps                                    */
    jcv_real   eps2;      /* eps^2                                    */
    int        nslots;    /* hash table size, power of two            */
    long long* slot_key;  /* packed cell key of the slot              */
    int*       slot_head; /* first point in the cell, -1 = empty slot */
    jcv_real*  px;        /* coordinates of the welded points         */
    jcv_real*  py;
    long long* pck;       /* cell key per point (for rehashing)       */
    int*       pnext;     /* next point in the same cell, -1 = none   */
    int        n;         /* number of welded (unique) points         */
    int        cap;       /* capacity of the point arrays             */
} jcvx_welder;

static long long jcvx__cellkey(long long cx, long long cy)
{
    return (long long)(((unsigned long long)(unsigned int)(int)cx << 32) |
                        (unsigned long long)(unsigned int)(int)cy);
}

static int jcvx__hash(long long key, int nslots)
{
    unsigned long long h = (unsigned long long)key;      /* murmur3 mix */
    h ^= h >> 33; h *= 0xff51afd7ed558ccdULL;
    h ^= h >> 33; h *= 0xc4ceb9fe1a85ec53ULL;
    h ^= h >> 33;
    return (int)(h & (unsigned long long)(nslots - 1));
}

/* slot of key (occupied or the empty slot where key would go) */
static int jcvx__slot(const jcvx_welder* w, long long key)
{
    int s = jcvx__hash(key, w->nslots);
    while (w->slot_head[s] != -1 && w->slot_key[s] != key)
        s = (s + 1) & (w->nslots - 1);
    return s;
}

static void jcvx__welder_rehash(jcvx_welder* w, int newslots)
{
    int i, p;
    free(w->slot_key); free(w->slot_head);
    w->nslots    = newslots;
    w->slot_key  = (long long*)malloc(sizeof(long long) * (size_t)newslots);
    w->slot_head = (int*)malloc(sizeof(int) * (size_t)newslots);
    for (i = 0; i < newslots; ++i) w->slot_head[i] = -1;
    for (p = 0; p < w->n; ++p) {
        int s = jcvx__slot(w, w->pck[p]);
        w->slot_key[s]  = w->pck[p];
        w->pnext[p]     = w->slot_head[s];
        w->slot_head[s] = p;
    }
}

static void jcvx_welder_init(jcvx_welder* w, int expected, jcv_real eps)
{
    int i, ns = 64;
    if (expected < 1) expected = 1;
    while (ns < 4 * expected && ns < (1 << 30)) ns <<= 1;
    w->inv_eps   = (jcv_real)1 / eps;
    w->eps2      = eps * eps;
    w->nslots    = ns;
    w->slot_key  = (long long*)malloc(sizeof(long long) * (size_t)ns);
    w->slot_head = (int*)malloc(sizeof(int) * (size_t)ns);
    for (i = 0; i < ns; ++i) w->slot_head[i] = -1;
    w->cap   = expected > 16 ? expected : 16;
    w->px    = (jcv_real*)malloc(sizeof(jcv_real) * (size_t)w->cap);
    w->py    = (jcv_real*)malloc(sizeof(jcv_real) * (size_t)w->cap);
    w->pck   = (long long*)malloc(sizeof(long long) * (size_t)w->cap);
    w->pnext = (int*)malloc(sizeof(int) * (size_t)w->cap);
    w->n = 0;
}

static void jcvx_welder_free(jcvx_welder* w)
{
    free(w->slot_key); free(w->slot_head);
    free(w->px); free(w->py); free(w->pck); free(w->pnext);
    memset(w, 0, sizeof(*w));
}

/* add point; returns the index of the representative it welds to,
 * or a fresh index (== previous w->n) if it is a new point */
static int jcvx_welder_add(jcvx_welder* w, jcv_real x, jcv_real y)
{
    long long cx = (long long)llround((double)(x * w->inv_eps));
    long long cy = (long long)llround((double)(y * w->inv_eps));
    long long i, j, key;
    int s, p;

    for (j = -1; j <= 1; ++j) {
        for (i = -1; i <= 1; ++i) {
            s = jcvx__slot(w, jcvx__cellkey(cx + i, cy + j));
            for (p = w->slot_head[s]; p != -1; p = w->pnext[p]) {
                jcv_real dx = w->px[p] - x, dy = w->py[p] - y;
                if (dx * dx + dy * dy <= w->eps2) return p;
            }
        }
    }

    /* new point */
    if (w->n == w->cap) {
        w->cap *= 2;
        w->px    = (jcv_real*)realloc(w->px,    sizeof(jcv_real) * (size_t)w->cap);
        w->py    = (jcv_real*)realloc(w->py,    sizeof(jcv_real) * (size_t)w->cap);
        w->pck   = (long long*)realloc(w->pck,  sizeof(long long) * (size_t)w->cap);
        w->pnext = (int*)realloc(w->pnext,      sizeof(int) * (size_t)w->cap);
    }
    if (2 * (w->n + 1) > w->nslots)
        jcvx__welder_rehash(w, w->nslots * 2);

    key = jcvx__cellkey(cx, cy);
    s = jcvx__slot(w, key);
    p = w->n++;
    w->px[p] = x; w->py[p] = y; w->pck[p] = key;
    w->slot_key[s]  = key;
    w->pnext[p]     = w->slot_head[s];
    w->slot_head[s] = p;
    return p;
}

/* ------------------------------------------------------------------ */
/* tolerance based input deduplication                                 */
/* map[i] (size n) receives the 0-based unique index of input point i; */
/* uniq (size >= n) receives the unique points in order of first       */
/* occurrence; returns the number of unique points.                    */
/* ------------------------------------------------------------------ */
static int jcvx_dedup_points(int n, const jcv_point* pts, jcv_real eps,
                             jcv_point* uniq, int* map)
{
    jcvx_welder w;
    int i, nu = 0;
    jcvx_welder_init(&w, n, eps);
    for (i = 0; i < n; ++i) {
        int u = jcvx_welder_add(&w, pts[i].x, pts[i].y);
        map[i] = u;
        if (u == nu) { uniq[nu] = pts[i]; ++nu; }
    }
    jcvx_welder_free(&w);
    return nu;
}

/* ------------------------------------------------------------------ */
/* jcv_diagram_generate with duplicate removal during construction     */
/* ------------------------------------------------------------------ */
#ifndef JCVX_NO_JC_VORONOI
static int jcvx_diagram_generate(int num_points, const jcv_point* points,
                                 jcv_real site_eps,
                                 const jcv_rect* rect,
                                 const jcv_clipper* clipper,
                                 jcv_diagram* diagram,
                                 int* sitemap /* out, size num_points */)
{
    jcv_point* uniq = (jcv_point*)malloc(sizeof(jcv_point) * (size_t)num_points);
    int nu = jcvx_dedup_points(num_points, points, site_eps, uniq, sitemap);
    jcv_diagram_generate(nu, uniq, rect, clipper, diagram);
    free(uniq); /* jc_voronoi copies the points into its own memory */
    return nu;
}
#endif

#endif /* JC_VORONOI_EXT_H */
