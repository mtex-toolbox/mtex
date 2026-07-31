/* jcvoronoi2_mex.cpp -- Voronoi decomposition for MTEX, second generation
 *
 * [V, F, I_FD, siteRep] = jcvoronoi2_mex(XY, numReal, eps)
 *
 * Input
 *   XY      - (numReal+numDummy) x 2 double; the first numReal rows are the
 *             measurement points, the remaining rows dummy boundary sites
 *   numReal - number of measurement points (leading rows of XY)
 *   eps     - welding tolerance, same units as XY (e.g. dxy/100):
 *             * input sites closer than eps are merged during construction
 *             * Voronoi vertices closer than eps are welded, edges shorter
 *               than eps collapse and are removed
 *
 * Output
 *   V       - nV x 2 vertex coordinates (unique within eps)
 *   F       - nF x 2 vertex indices (1-based), one row per unique boundary
 *             segment adjacent to at least one measurement point
 *   I_FD    - nF x numReal sparse incidence matrix segment x point;
 *             duplicated input points share the columns of their
 *             representative, so no column of a measurement point is empty
 *   siteRep - (optional) (numReal+numDummy) x 1, 1-based index of the
 *             representative input site each site was merged into
 *             (siteRep(i) == i for sites that were kept)
 *
 * Internally the coordinates are shifted to the bounding-box center before
 * running Fortune's algorithm, which avoids burning double precision on
 * large stage offsets.
 *
 * Build:  mex jcvoronoi2_mex.cpp
 *         (jc_voronoi.h and jc_voronoi_ext.h in the same directory)
 */

#include <cmath>
#include <cstring>
#include <cstdint>
#include <vector>
#include <algorithm>
#include <utility>

#define JC_VORONOI_IMPLEMENTATION
#define JCV_REAL_TYPE double
#define JCV_ATAN2 atan2
#define JCV_SQRT sqrt
#define JCV_FABS fabs
#define JCV_FLT_MAX 1.7976931348623157E+308
#define JCV_PI 3.141592653589793115997963468544185161590576171875
#include "jc_voronoi.h"
#include "jc_voronoi_ext.h"

#include "mex.hpp"
#include "mexAdapter.hpp"

using matlab::mex::ArgumentList;
namespace md = matlab::data;

// jc_voronoi (since the 2026-07-20 "unique vertex indices" release) already
// recognizes *some* duplicate endpoints itself: edge.vertices[k] is set to a
// shared index whenever this exact circle-event vertex was already stamped
// onto a neighbouring edge (bit-exact match only, see jcv_circle_event).
// weldIdOf caches that upstream index -> our welder's compacted id, so an
// endpoint upstream already proved identical skips the eps hash-grid probe
// entirely. Endpoints upstream couldn't resolve (JCV_INVALID_VERTEX, or the
// first time an index is seen) fall through to jcvx_welder_add exactly as
// before - this is a pure cache, it changes no eps-tolerance semantics.
static inline int jcvx_welded_id(int upstreamIdx, const jcv_point& p,
                                  std::vector<int>& weldIdOf, jcvx_welder& vw)
{
  if (upstreamIdx != JCV_INVALID_VERTEX && weldIdOf[(size_t)upstreamIdx] >= 0)
    return weldIdOf[(size_t)upstreamIdx];
  const int id = jcvx_welder_add(&vw, p.x, p.y);
  if (upstreamIdx != JCV_INVALID_VERTEX) weldIdOf[(size_t)upstreamIdx] = id;
  return id;
}

class MexFunction : public matlab::mex::Function {

  std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
  md::ArrayFactory factory;

  void err(const std::string& msg) {
    matlabPtr->feval(u"error", 0,
      std::vector<md::Array>({ factory.createScalar("jcvoronoi2_mex: " + msg) }));
  }

public:
  void operator()(ArgumentList outputs, ArgumentList inputs) {

    // ---------------------------------------------------------- parse input
    if (inputs.size() != 3)
      err("expected three inputs: XY (n x 2 double), numReal, eps");

    md::TypedArray<double> XY = std::move(inputs[0]);
    const md::ArrayDimensions dims = XY.getDimensions();
    if (dims.size() != 2 || dims[1] != 2) err("XY must be n x 2");
    const size_t nAll = dims[0];

    const double nRealD = md::TypedArray<double>(inputs[1])[0];
    const double eps    = md::TypedArray<double>(inputs[2])[0];
    if (nRealD < 0 || nRealD != std::floor(nRealD) || (size_t)nRealD > nAll)
      err("numReal must be an integer between 0 and size(XY,1)");
    if (!(eps > 0)) err("eps must be positive");
    const size_t nReal = (size_t)nRealD;

    // copy out of the MATLAB array (column major: first nAll x, then nAll y)
    std::vector<double> xy(XY.begin(), XY.end());

    // ------------------------------------------- center coordinates, checks
    double xmin =  JCV_FLT_MAX, xmax = -JCV_FLT_MAX;
    double ymin =  JCV_FLT_MAX, ymax = -JCV_FLT_MAX;
    for (size_t i = 0; i < nAll; ++i) {
      xmin = std::min(xmin, xy[i]);        xmax = std::max(xmax, xy[i]);
      ymin = std::min(ymin, xy[nAll + i]); ymax = std::max(ymax, xy[nAll + i]);
    }
    const double cx0 = 0.5 * (xmin + xmax), cy0 = 0.5 * (ymin + ymax);

    const double maxAbs = std::max(xmax - cx0, ymax - cy0);
    if (maxAbs / eps > 2.0e9)
      err("eps is too small relative to the map extent (quantization overflow)");

    std::vector<jcv_point> pts(nAll);
    for (size_t i = 0; i < nAll; ++i) {
      pts[i].x = xy[i]        - cx0;
      pts[i].y = xy[nAll + i] - cy0;
    }

    // Break grid degeneracy for the dummy (boundary) sites. On a regular grid
    // a real cell, the dummy directly outside it, and the two lateral real
    // neighbours are exactly co-circular; Fortune's algorithm resolves that
    // four-fold degeneracy arbitrarily and often omits the real->dummy edge,
    // so straight outer edges (e.g. a flat bottom row) lose their boundary
    // faces and vertices while ragged edges survive. Dummies are throwaway
    // sites (their cells are discarded; only the real-dummy faces matter), so
    // we may perturb them freely. A small deterministic jitter, comfortably
    // below the grid spacing but above the weld tolerance, removes the
    // degeneracy without visibly moving the boundary. Real sites are left
    // untouched.
    if (nAll > nReal) {
      // jitter amplitude: a fixed fraction of the weld tolerance, so it is
      // always below eps (interior quadruple points still weld) yet enough to
      // break the boundary degeneracy. Independent of map extent.
      const double amp = 0.2 * eps;
      for (size_t i = nReal; i < nAll; ++i) {
        // deterministic hash of the index -> two offsets in [-0.5,0.5]
        uint64_t h = (uint64_t)(i + 1) * 0x9E3779B97F4A7C15ull;
        h ^= h >> 29; h *= 0xBF58476D1CE4E5B9ull; h ^= h >> 32;
        const double jx = ((double)((h      ) & 0xFFFF) / 65535.0 - 0.5);
        const double jy = ((double)((h >> 16) & 0xFFFF) / 65535.0 - 0.5);
        pts[i].x += amp * jx;
        pts[i].y += amp * jy;
      }
    }

    // ------------------------- Voronoi with site dedup during construction
    std::vector<int> sitemap(nAll);   // input index -> unique site index
    jcv_diagram diagram;
    std::memset(&diagram, 0, sizeof(diagram));
    const int nU = jcvx_diagram_generate((int)nAll, pts.data(), eps,
                                         nullptr, nullptr, &diagram,
                                         sitemap.data());

    std::vector<char> uniqueIsReal((size_t)nU, 0);
    for (size_t i = 0; i < nReal; ++i) uniqueIsReal[(size_t)sitemap[i]] = 1;

    // ------------------------------- edge pass: weld vertices, build edges
    jcvx_welder vw;
    jcvx_welder_init(&vw, 2 * nU, eps);

    // cache from jc_voronoi's own (bit-exact) vertex index to our welder id
    std::vector<int> weldIdOf((size_t)jcv_get_num_vertices(&diagram), -1);

    std::vector<int> ea, eb;               // vertex pair per kept edge (row)
    // incidences (unique-site, row) collected as two parallel arrays; deduped
    // later by a counting sort over sites (no comparison sort, no hash map).
    std::vector<int> incSite, incRow;
    ea.reserve((size_t)nU * 3); eb.reserve((size_t)nU * 3);
    incSite.reserve((size_t)nU * 6); incRow.reserve((size_t)nU * 6);

    jcv_edge_iter edgeIter;
    jcv_edge e;
    jcv_diagram_get_edges(&diagram, &edgeIter);
    while (jcv_edge_next(&edgeIter, &e)) {

      const jcv_site* s0 = e.sites[0];
      const jcv_site* s1 = e.sites[1];
      const bool r0 = s0 && uniqueIsReal[(size_t)s0->index];
      const bool r1 = s1 && uniqueIsReal[(size_t)s1->index];
      if (!r0 && !r1) continue;                  // between dummies only

      int v1 = jcvx_welded_id(e.vertices[0], e.pos[0], weldIdOf, vw);
      int v2 = jcvx_welded_id(e.vertices[1], e.pos[1], weldIdOf, vw);
      if (v1 == v2) continue;                    // collapsed short edge
      if (v1 > v2) std::swap(v1, v2);

      // Each jc_voronoi edge is emitted once, so assign a fresh row directly.
      // In the rare case two distinct edges weld to the same vertex pair we
      // get two rows with identical geometry; that is harmless (the incidence
      // dedup below keeps the sparse matrix well formed).
      const int row = (int)ea.size();
      ea.push_back(v1); eb.push_back(v2);

      if (r0) { incSite.push_back(s0->index); incRow.push_back(row); }
      if (r1) { incSite.push_back(s1->index); incRow.push_back(row); }
    }
    jcv_diagram_free(&diagram);

    const size_t nF = ea.size();
    const size_t nV = (size_t)vw.n;
    const size_t nInc = incSite.size();

    // ------------------------ incidences -> CSR by unique site (counting sort)
    // ustart[u]..ustart[u+1] will index the rows incident to unique site u.
    std::vector<size_t> ustart((size_t)nU + 1, 0);
    for (size_t k = 0; k < nInc; ++k) ++ustart[(size_t)incSite[k] + 1];
    for (size_t u = 0; u < (size_t)nU; ++u) ustart[u + 1] += ustart[u];

    std::vector<int> rowBySite(nInc);
    {
      std::vector<size_t> cur(ustart.begin(), ustart.end());
      for (size_t k = 0; k < nInc; ++k)
        rowBySite[cur[(size_t)incSite[k]]++] = incRow[k];
    }

    // count nnz over real columns (duplicated input sites share a site's rows)
    size_t nnz = 0;
    for (size_t i = 0; i < nReal; ++i) {
      const size_t u = (size_t)sitemap[i];
      nnz += ustart[u + 1] - ustart[u];
    }

    // ------------------------------------------------------------- outputs
    // V (shift back to original coordinates)
    md::buffer_ptr_t<double> vbuf = factory.createBuffer<double>(nV * 2);
    for (size_t j = 0; j < nV; ++j) {
      vbuf[j]      = vw.px[j] + cx0;
      vbuf[nV + j] = vw.py[j] + cy0;
    }
    jcvx_welder_free(&vw);
    outputs[0] = factory.createArrayFromBuffer<double>({nV, 2}, std::move(vbuf));

    // F (1-based)
    md::buffer_ptr_t<double> fbuf = factory.createBuffer<double>(nF * 2);
    for (size_t k = 0; k < nF; ++k) {
      fbuf[k]      = (double)(ea[k] + 1);
      fbuf[nF + k] = (double)(eb[k] + 1);
    }
    outputs[1] = factory.createArrayFromBuffer<double>({nF, 2}, std::move(fbuf));

    // I_FD sparse, column major; rows within each column must be ascending
    md::buffer_ptr_t<double> dbuf = factory.createBuffer<double>(nnz);
    md::buffer_ptr_t<size_t> rbuf = factory.createBuffer<size_t>(nnz);
    md::buffer_ptr_t<size_t> cbuf = factory.createBuffer<size_t>(nnz);
    size_t pos = 0;
    for (size_t i = 0; i < nReal; ++i) {
      const size_t u = (size_t)sitemap[i];
      const size_t a = ustart[u], b = ustart[u + 1];
      // sort this site's (few) rows ascending; dedup twin rows
      std::sort(rowBySite.begin() + a, rowBySite.begin() + b);
      int last = -1;
      for (size_t k = a; k < b; ++k) {
        const int rr = rowBySite[k];
        if (rr == last) continue;                // drop duplicate row
        dbuf[pos] = 1.0;
        rbuf[pos] = (size_t)rr;
        cbuf[pos] = i;
        ++pos;
        last = rr;
      }
    }
    const size_t nnzActual = pos;
    outputs[2] = factory.createSparseArray<double>({nF, nReal}, nnzActual,
                   std::move(dbuf), std::move(rbuf), std::move(cbuf));

    // optional: representative input site (1-based) after dedup
    if (outputs.size() > 3) {
      std::vector<int> rep((size_t)nU, -1);
      for (size_t i = 0; i < nAll; ++i)
        if (rep[(size_t)sitemap[i]] < 0) rep[(size_t)sitemap[i]] = (int)i;
      md::buffer_ptr_t<double> mbuf = factory.createBuffer<double>(nAll);
      for (size_t i = 0; i < nAll; ++i)
        mbuf[i] = (double)(rep[(size_t)sitemap[i]] + 1);
      outputs[3] = factory.createArrayFromBuffer<double>({nAll, 1}, std::move(mbuf));
    }
  }
};
