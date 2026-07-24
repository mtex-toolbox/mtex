/* jcvoronoiDelaunayOnly_mex.cpp -- Delaunay-adjacency-only pass for MTEX
 *
 * [I_FD] = jcvoronoiDelaunayOnly_mex(XY, numReal, eps)
 *
 * Same input contract as jcvoronoi2_mex, but only the site-to-site adjacency
 * needed by doSegmentation.m's A_D = I_FD'*I_FD==1 is computed - no Voronoi
 * vertex placement, edge clipping, or gap filling. Used exclusively for
 * calcGrains' first (minPixel sizing) pass, which never looks at V/F; the
 * real second pass keeps calling jcvoronoi2_mex for the full geometry.
 *
 * Input
 *   XY      - (numReal+numDummy) x 2 double; the first numReal rows are the
 *             measurement points, the remaining rows dummy boundary sites
 *   numReal - number of measurement points (leading rows of XY)
 *   eps     - welding tolerance, same units as XY (e.g. dxy/100), see
 *             jcvoronoi2_mex
 *
 * Output
 *   I_FD    - nF x numReal sparse incidence matrix segment x point, one row
 *             per Delaunay adjacency touching at least one measurement
 *             point; duplicated input points share the columns of their
 *             representative. Row count and content are NOT comparable to
 *             jcvoronoi2_mex's I_FD (no vertex welding/collapsing of short
 *             edges happens here); the resulting site adjacency
 *             A_D = I_FD'*I_FD==1 is a SUPERSET of jcvoronoi2_mex's, not
 *             guaranteed to match exactly - see check_jcvoronoiDelaunayOnly.
 *             On an exactly regular/rigid grid, every interior vertex has 4
 *             exactly-cocircular sites; Fortune's sweep arbitrarily keeps one
 *             diagonal as a Delaunay edge there even though the true Voronoi
 *             cells only touch at a point (zero-length shared edge, which
 *             jcvoronoi2_mex drops via vertex welding). No vertex/edge-length
 *             information survives jcv_delauney_generate, so this cannot be
 *             filtered here without recomputing the circumcenters - which
 *             would defeat the point of skipping the full Voronoi build.
 *             Safe for calcGrains' minPixel sizing pass: extra adjacency only
 *             makes computed grain sizes >= the true ones, so it never
 *             over-culls, only very rarely under-culls a diagonal contact.
 *
 * Build:  mex jcvoronoiDelaunayOnly_mex.cpp
 *         (jc_voronoi.h and jc_voronoi_ext.h in the same directory)
 */

#include <cmath>
#include <cstring>
#include <cstdint>
#include <vector>
#include <algorithm>

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

class MexFunction : public matlab::mex::Function {

  std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
  md::ArrayFactory factory;

  void err(const std::string& msg) {
    matlabPtr->feval(u"error", 0,
      std::vector<md::Array>({ factory.createScalar("jcvoronoiDelaunayOnly_mex: " + msg) }));
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

    // Same deterministic dummy-site jitter as jcvoronoi2_mex, and for the
    // same reason: on a regular grid a real cell, the dummy directly outside
    // it, and its two lateral real neighbours are exactly co-circular, so
    // Fortune's algorithm can arbitrarily drop the real-dummy adjacency edge.
    // Must match jcvoronoi2_mex bit-for-bit so both mex produce the same
    // adjacency on the same input (verified by check_jcvoronoiDelaunayOnly).
    if (nAll > nReal) {
      const double amp = 0.2 * eps;
      for (size_t i = nReal; i < nAll; ++i) {
        uint64_t h = (uint64_t)(i + 1) * 0x9E3779B97F4A7C15ull;
        h ^= h >> 29; h *= 0xBF58476D1CE4E5B9ull; h ^= h >> 32;
        const double jx = ((double)((h      ) & 0xFFFF) / 65535.0 - 0.5);
        const double jy = ((double)((h >> 16) & 0xFFFF) / 65535.0 - 0.5);
        pts[i].x += amp * jx;
        pts[i].y += amp * jy;
      }
    }

    // ------------------------- Delaunay-only diagram, site dedup during build
    std::vector<int> sitemap(nAll);   // input index -> unique site index
    jcv_diagram diagram;
    std::memset(&diagram, 0, sizeof(diagram));
    const int nU = jcvx_delauney_diagram_generate((int)nAll, pts.data(), eps,
                                                  nullptr, nullptr, &diagram,
                                                  sitemap.data());

    std::vector<char> uniqueIsReal((size_t)nU, 0);
    for (size_t i = 0; i < nReal; ++i) uniqueIsReal[(size_t)sitemap[i]] = 1;

    // ------------------------------------ adjacency pass: walk Delauney edges
    // incidences (unique-site, row) collected as two parallel arrays; deduped
    // later by a counting sort over sites (no comparison sort, no hash map).
    std::vector<int> incSite, incRow;
    incSite.reserve((size_t)nU * 6); incRow.reserve((size_t)nU * 6);

    jcv_delauney_iter dIter;
    jcv_delauney_edge de;
    jcv_delauney_begin(&diagram, &dIter);
    int nF = 0;
    while (jcv_delauney_next(&dIter, &de)) {

      const bool r0 = de.sites[0] && uniqueIsReal[(size_t)de.sites[0]->index];
      const bool r1 = de.sites[1] && uniqueIsReal[(size_t)de.sites[1]->index];
      if (!r0 && !r1) continue;                  // between dummies only

      const int row = nF++;
      if (r0) { incSite.push_back(de.sites[0]->index); incRow.push_back(row); }
      if (r1) { incSite.push_back(de.sites[1]->index); incRow.push_back(row); }
    }
    jcv_diagram_free(&diagram);

    const size_t nInc = incSite.size();

    // ------------------------ incidences -> CSR by unique site (counting sort)
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

    // ------------------------------------------------------------- output
    // I_FD sparse, column major; rows within each column must be ascending
    md::buffer_ptr_t<double> dbuf = factory.createBuffer<double>(nnz);
    md::buffer_ptr_t<size_t> rbuf = factory.createBuffer<size_t>(nnz);
    md::buffer_ptr_t<size_t> cbuf = factory.createBuffer<size_t>(nnz);
    size_t pos = 0;
    for (size_t i = 0; i < nReal; ++i) {
      const size_t u = (size_t)sitemap[i];
      const size_t a = ustart[u], b = ustart[u + 1];
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
    outputs[0] = factory.createSparseArray<double>({(size_t)nF, nReal}, nnzActual,
                   std::move(dbuf), std::move(rbuf), std::move(cbuf));
  }
};
