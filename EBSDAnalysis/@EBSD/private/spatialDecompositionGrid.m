function out = spatialDecompositionGrid(ebsd,varargin)
% grid-based spatial decomposition for grain reconstruction (square + hex)
%
% Implements the unified pipeline discussed in DESIGN.md. Every gridified
% cell ends up classified as an indexed site, a kept dummy, or a notIndexed
% site; indexed and notIndexed sites become grains, dummies only bound the
% outer cells. Empty cells and input-notIndexed pixels are treated
% identically.
%
% minPixel culling is NOT done here. Because the alpha closing connects grain
% pixels across bridged gaps and diagonals (via the Voronoi face adjacency),
% grain sizes can only be measured correctly on the real decomposition. The
% minPixel filter is therefore applied by the caller (calcGrains2) as a
% two-pass scheme: decompose once, segment, cull undersized indexed grains by
% marking their pixels notIndexed, then decompose again.
%
% cells2posId (see there) places every site that has no real measurement -
% notIndexed holes, the exterior dummy ring bounding the map edge, filled
% small gaps - via a local deformation model (see reconstructPos above),
% not a single rigid affine ij*A' + origin: under a smooth but non-rigid
% distortion (e.g. a trapezoidal stage drift, see EBSD/transform) a rigid
% reconstruction disagrees with where a genuinely measured pixel at that
% index would actually sit, shifting Voronoi boundaries near every hole and
% the whole map edge and manufacturing spurious extra grains. Wherever a
% real ebsd row exists at a hole's grid slot (e.g. a genuinely scanned but
% notIndexed pixel), its true measured position is used directly instead of
% any reconstruction - see cells2posId.
%
% Syntax
%   out = spatialDecompositionGrid(ebsd,'alpha',1.5)
%
% Input
%  ebsd - gridified @EBSDsquare / @EBSDhex
%
% Options
%  alpha    - hole closing radius in multiples of dxy (default 1.5). Holes
%             narrower than 2*alpha*dxy are filled and vanish; wider holes are
%             preserved as measured (no growing into them). Single-pixel-wide
%             recesses (boundary notches, slit mouths) are always filled for
%             alpha >= 1, matching the alpha shape.
%
% Output struct out with fields
%  V        - nV x 2 Voronoi vertices
%  F        - nF x 2 vertex indices per boundary segment (1-based)
%  I_FD     - nF x nSites sparse incidence (segment x site), sites = grains
%  isNotIdx - nSites x 1 logical, which sites are notIndexed grains
%  site2id  - nSites x 1, ebsd linear index for indexed sites, NaN for
%             notIndexed sites that came from empty cells
%  ij       - nEbsd x 2 axial indices (debug)

alpha = get_option(varargin,'alpha',3.1);

% transform positions to ij grid
g = ebsd.lattice;
A = g.A; stencil = g.stencil; dxy = g.dxy; ij = g.ij;
epsilon = dxy/100;

pos = [ebsd.pos.x(:), ebsd.pos.y(:)];
nE       = size(pos,1);
isIndexed = ebsd.isIndexed(:);

% fast neighbour lookup
% ij2ebsd(ij2slot([i j])) is the ebsd index / 0 if not contained in the map
[ij2ebsd,ij2slot,ijmin,ijsz] = latticeLookup(ij);

% local model to reconstruct the position of grid cells with no real
% measurement (notIndexed holes, the dummy/band ring, filled small gaps).
% A single rigid affine (ij*A' + a fixed origin) disagrees with the true
% position under smooth non-rigid distortion (e.g. a trapezoidal stage
% drift, see EBSD/transform) - it shifts Voronoi boundaries near every
% hole/edge and manufactures spurious extra grains. Instead fit the ideal
% affine lattice to the indexed pixels, then interpolate the *local*
% deviation between real positions and that ideal grid in index space -
% same technique as calcMesh - and evaluate it at cells with no data.
% scatteredInterpolant requires double; ij/pos can come in as single
% (e.g. real imported EBSD data)
Iidx = double(ij(isIndexed,1)); Jidx = double(ij(isIndexed,2));
posIdx = double(pos(isIndexed,:));
idealFit  = [ones(numel(Iidx),1), Iidx, Jidx] \ posIdx;
idealFun  = @(IJ) [ones(size(IJ,1),1), double(IJ)] * idealFit;
defXY     = posIdx - idealFun([Iidx, Jidx]);

% fast path: most EBSD grids are already (near-)rigid, so the ideal affine
% grid alone reconstructs unmeasured positions accurately enough and the
% deformation term below is negligible. Building it anyway is expensive -
% two natural-neighbour scatteredInterpolant fits (each a Delaunay
% triangulation over every indexed pixel) - so skip it whenever the affine
% residual is small relative to the grid spacing, same check calcMesh uses
% to decide whether its ideal grid is "sufficiently good". Only genuinely
% distorted grids (e.g. smooth stage drift) fall through to the accurate,
% slower route.
if mean(vecnorm(defXY,2,2)) / dxy < 1e-2
  reconstructPos = @(IJ) idealFun(IJ);
else
  Fx = scatteredInterpolant(Iidx, Jidx, defXY(:,1), 'natural', 'nearest');
  Fy = scatteredInterpolant(Iidx, Jidx, defXY(:,2), 'natural', 'nearest');
  % reshape guards against scatteredInterpolant returning 0x0 (not 0x1) for
  % an empty query, which would otherwise break the '+' below
  reconstructPos = @(IJ) idealFun(IJ) + ...
    [reshape(Fx(double(IJ(:,1)),double(IJ(:,2))),[],1), reshape(Fy(double(IJ(:,1)),double(IJ(:,2))),[],1)];
end

% ---- alpha partition via morphological closing -----------------------------
% Work on a padded raster of the (i,j) grid. All operations below are binary
% 2D morphology, linearised over the padded raster for speed.

rClose  = alpha*dxy;                            % closing radius: fills holes of
                                                % diameter < 2*rClose = 2*alpha*dxy
% Padding must leave room for (i) the closing, which can push the material
% outward by up to rClose before the erosion, and (ii) at least one exterior
% cell beyond that for the dummy ring to sit in. If the material ever reaches
% the padded border, the flood fill cannot wrap around it, no dummies are
% placed there, and the outer grains come out open. So size the margin from
% the closing reach in cells PLUS a fixed safety of 2 cells, independent of A.
closeCells = ceil(rClose / min(vecnorm(A,2,1)));
padding = closeCells + 4;   % closing reach + band (1) + pushed band (1) + dummy ring (1) + safety (1)
szP     = ijsz + 2*padding;
ij2slotP = @(IJ) (IJ(:,1)-ijmin(1)+padding) + (IJ(:,2)-ijmin(2)+padding)*szP(1) + 1;

% padded binary mask of indexed pixels
isIndexedP = false(prod(szP),1);
isIndexedP(ij2slotP(ij(isIndexed,:))) = true;
% imagesc(reshape(isIndexedP,szP)), axis equal tight

% structuring element: disk of radius rClose, as (i,j) offsets
wi = ceil(rClose / vecnorm(A(:,1))) + 1;
wj = ceil(rClose / vecnorm(A(:,2))) + 1;
[di,dj] = meshgrid(-wi:wi, -wj:wj);
dxyDisk = [di(:) dj(:)] * A';                   % physical displacement of each offset
inDisk  = sum(dxyDisk.^2,2) <= rClose^2;
diskOffs = [di(inDisk) dj(inDisk)];             % <-- disk structuring element
% imagesc(reshape(inDisk,size(di))), axis equal tight

% add lateral companions next to the axis extremes of the disk. A recess cell
% at a straight boundary survives the erosion only if the dilation covers the
% disk extreme M*s above it (s = stencil direction, M = axis reach); that
% coverage can only come from the recess' lateral neighbours t, which requires
% M*s-t to be in the disk. Whenever alpha^2 - floor(alpha)^2 < 1 (worst case:
% integer alpha) the sampled disk lacks exactly those points - the extreme is
% a lone single-cell tip - and boundary recesses that the alpha shape would
% close stay open, visible as bumps in the outer grain boundary. Adding the
% companions never extends the axis reach, so wider holes are still preserved.
comp = zeros(0,2);
for s = 1:size(stencil,1)
  Ms = floor(rClose / norm(stencil(s,:)*A'));
  if Ms < 1, continue; end
  t = stencil(~all(stencil == stencil(s,:) | stencil == -stencil(s,:), 2),:);
  comp = [comp; Ms*stencil(s,:) - t]; %#ok<AGROW>
end
diskOffs = unique([diskOffs; comp],'rows');

% morphological CLOSING of the indexed set by the disk:
%   closedP = erode(dilate(isIndexedP)) , erosion done as the complement of the
%   dilation of the complement (De Morgan). Fills holes/slits narrower than
%   2*alpha*dxy, preserves wider holes, and is extensive (never drops an
%   indexed cell). The final "| isIndexedP" is a safety belt against discretisation.
dilatedP = binaryDilate(isIndexedP, diskOffs, szP);      % 2D binary dilation
closedP  = ~binaryDilate(~dilatedP, diskOffs, szP);      % 2D binary erosion
closedP  = closedP | isIndexedP;
% imagesc(reshape(dilatedP,szP)), axis equal tight
% imagesc(reshape(closedP,szP)), axis equal tight

% fill single-pixel concavities: a background cell with material on more than
% half of its stencil directions is a 1-wide dead-end recess (boundary notch,
% slit mouth). The alpha shape fills those for any alpha >= 1, but the sampled
% disk closing misses them whenever alpha^2 - floor(alpha)^2 < 1: the SE then
% has a lone single-cell tip at its axis extreme (0,+-floor(alpha)) that the
% dilation from the recess' lateral neighbours cannot cover - worst for
% integer alpha. Iterate because filling a slit mouth exposes the next cell;
% wider holes and open channels (<= half the stencil material) stay untouched.
if alpha >= 1
  nMin = floor(size(stencil,1)/2) + 1;
  while true
    add = ~closedP & stencilCount(closedP, stencil, szP) >= nMin;
    if ~any(add), break; end
    closedP(add) = true;
  end
end

% exteriorP = background connected to the padded border. This is a flood fill
% (morphological reconstruction of the border marker under the mask ~closedP),
% here computed as connected components of ~closedP with border-touching label.
exteriorP = floodFillBorder(~closedP, stencil, szP);   % 2D flood fill
% imagesc(reshape(exteriorP,szP)), axis equal tight

% guard: material must be strictly inside the padded raster, else the dummy
% ring is truncated at the border and the outer grains come out open
matP = reshape(~exteriorP, szP);
assert(~any([matP(1,:), matP(end,:), matP(:,1).', matP(:,end).']), ...
  'spatialDecompositionGrid:padding', ...
  'material reaches the padded border - dummy ring truncated; increase padding');

% classification of every padded raster cell:
%   isIndexedP                    -> indexed site
%   bigHoleP  = ~closedP & ~exteriorP  -> notIndexed site (enclosed large hole)
%   closedP & ~isIndexedP         -> filled small hole: NO site (neighbours grow in)
%   extBandP  = 1-cell exterior shell -> notIndexed site (NaN id): makes the
%               OUTER boundary a grain-vs-grain boundary, so it is regularised
%               by alpha exactly like interior holes instead of following the
%               raw pixel staircase of a bare dummy ring. It carries no ebsd
%               pixel, so remapIFD drops its column and it never becomes a
%               listed grain (no outside grain).
%   dummyP    = ring beyond the band  -> bounds the band's own cells
materialP = ~exteriorP;                                % isIndexedP + filled holes + bigHoleP
bigHoleP  = ~closedP & ~exteriorP;

% one-cell exterior shell adjacent to the material
extBandP  = binaryDilate(materialP, stencil, szP) & exteriorP;

% a band cell whose only material contact is a filled (site-less) cell sits at
% half the regular site-to-site distance across the boundary: its Voronoi cell
% dips half a pixel into the filled recess (V-shaped bump in the outer
% boundary). The same applies to band cells inside shallow recesses (1-deep
% dents wider than the closing can bridge on the lattice): there the boundary
% would follow the full pixel staircase although the alpha shape absorbs such
% cells. Vacate both kinds of cells and push the band one cell further out;
% the vacated cell must stay empty (no band, no dummy), then the boundary runs
% straight across filled recesses and dips only half a pixel into shallow ones.
siteCellsP = isIndexedP | bigHoleP;

% shallow recess = material within the closing reach on BOTH sides along some
% lattice direction (exterior channels of that width are already filled by the
% closing, so this cannot glue separate map regions)
recessP = false(prod(szP),1);
hasDir  = false(prod(szP),size(stencil,1));
for s = 1:size(stencil,1)
  Ms = floor(rClose / norm(stencil(s,:)*A'));
  hasDir(:,s) = binaryDilate(materialP, -(1:Ms)'*stencil(s,:), szP);
end
for s = 1:size(stencil,1)
  [~,o] = ismember(-stencil(s,:),stencil,'rows');
  if o > s, recessP = recessP | (hasDir(:,s) & hasDir(:,o)); end
end

vacatedP = extBandP & (~binaryDilate(siteCellsP, stencil, szP) | recessP);
extBandP = extBandP & ~vacatedP;
pushP    = binaryDilate(vacatedP, stencil, szP) & exteriorP & ~vacatedP & ~extBandP;
extBandP = extBandP | pushP;

% dummy ring one cell beyond the band (bounds the band cells)
dummyP    = binaryDilate(materialP | extBandP, stencil, szP) & exteriorP & ~extBandP & ~vacatedP;
% imagesc(reshape(bigHoleP,szP)), axis equal tight
% imagesc(reshape(extBandP,szP)), axis equal tight
% imagesc(reshape(dummyP,szP)), axis equal tight

% ---- assemble sites --------------------------------------------------------
% indexed sites (kept measurements)
idxSiteEbsd = find(isIndexed);
sitesIdx    = pos(idxSiteEbsd,:);

% notIndexed sites: interior large holes (recover ebsd id where a pixel
% exists) plus the exterior band (never has an ebsd pixel -> NaN id, so it is
% dropped from the grain list by remapIFD while still smoothing the boundary)
[holePos, holeId] = cells2posId(bigHoleP, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);
[bandPos, ~     ] = cells2posId(extBandP, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);
niPos = [holePos; bandPos];
niId  = [holeId ; nan(size(bandPos,1),1)];
% dummy sites (outer shell) - never carry an id
[dumPos, ~    ] = cells2posId(dummyP , szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);

% real (=grain) sites first: indexed then notIndexed; dummies last
XY      = [sitesIdx; niPos; dumPos];
numReal = size(sitesIdx,1) + size(niPos,1);

isNotIdx = [false(size(sitesIdx,1),1); true(size(niPos,1),1)];
site2id  = [idxSiteEbsd; niId];

% ---- Voronoi -----------------------------------------------------------
% 'delaunayOnly' is internal-only (not a user-facing option): calcGrains'
% minPixel sizing pass (minPixelMask.m) only ever needs the site-to-site
% adjacency doSegmentation.m builds from I_FD, never the V/F geometry, so it
% requests the cheaper Delaunay-adjacency-only mex here. The real second
% decomposition pass (calcGrains.m) never sets this flag and keeps getting
% full Voronoi geometry.
%
% Caveat: on an exactly regular/rigid grid, jcvoronoiDelaunayOnly_mex's
% adjacency is a strict superset of jcvoronoi2_mex's - it can report a
% spurious diagonal adjacency at an exactly-cocircular interior vertex that
% the full Voronoi build correctly excludes (see check_jcvoronoiDelaunayOnly
% and minPixelMask.m). Never a missing adjacency, so this is safe for a
% sizing-only pass.
if check_option(varargin,'delaunayOnly')
  V = zeros(0,2); F = zeros(0,2);
  I_FD = jcvoronoiDelaunayOnly(double(XY),double(numReal), double(epsilon));
else
  [V,F,I_FD] = jcvoronoi2(double(XY),double(numReal), double(epsilon));
end

out = struct('V',V,'F',F,'I_FD',I_FD, ...
             'isNotIdx',isNotIdx,'site2id',site2id,'ij',ij);
end

% ===========================================================================
function m2 = binaryDilate(m, offs, szP)
% binary morphological dilation of mask m (prod(szP) x 1 logical) by the
% structuring element `offs`, given as [di dj] axial (i,j) offsets. Consistent
% with the flatten ij2slotP, i is the row (dim 1) and j is the column (dim 2),
% so an offset's 1st component moves the row and its 2nd component the column.
%
% Implemented as an OR of shifted submatrix slices of the 2D mask: cheaper
% than scattering foreground index vectors, in particular for the (mostly
% dense) masks this file works on, and free of find/ind2sub/sub2ind.
M  = reshape(m, szP);
M2 = false(szP);
n1 = szP(1); n2 = szP(2);
for o = 1:size(offs,1)
  di = offs(o,1); dj = offs(o,2);               % i-step -> row, j-step -> col
  r = max(1,1+di):min(n1,n1+di);                % target rows with valid source
  c = max(1,1+dj):min(n2,n2+dj);
  if isempty(r) || isempty(c), continue; end
  M2(r,c) = M2(r,c) | M(r-di, c-dj);
end
m2 = M2(:);
end

% ===========================================================================
function cnt = stencilCount(m, offs, szP)
% number of foreground cells of m (prod(szP) x 1 logical) among the stencil
% neighbours of every raster cell. Same shifted-slice scheme as binaryDilate,
% but accumulating a count instead of OR-ing.
M   = reshape(m, szP);
CNT = zeros(szP);
n1 = szP(1); n2 = szP(2);
for o = 1:size(offs,1)
  di = offs(o,1); dj = offs(o,2);               % i-step -> row, j-step -> col
  r = max(1,1+di):min(n1,n1+di);
  c = max(1,1+dj):min(n2,n2+dj);
  if isempty(r) || isempty(c), continue; end
  CNT(r,c) = CNT(r,c) + M(r-di, c-dj);
end
cnt = CNT(:);
end

% ===========================================================================
function ext = floodFillBorder(bg, stencil, szP)
% flood fill: mark all background (bg) cells connected to the padded border.
% Implemented as connected components of bg over the stencil adjacency, then
% keeping components that contain a border cell. Equivalent to a morphological
% reconstruction of the border marker under the mask bg.
bgLin = find(bg);
nb = numel(bgLin);
compact = zeros(prod(szP),1); compact(bgLin) = 1:nb;
[rr,cc] = ind2sub(szP, bgLin);

srcE = []; dstE = [];
for s = 1:size(stencil,1)
  r2 = rr + stencil(s,1);  c2 = cc + stencil(s,2);   % i-step -> row, j-step -> col
  ok = find(r2>=1 & r2<=szP(1) & c2>=1 & c2<=szP(2));
  l2 = r2(ok) + (c2(ok)-1)*szP(1);   % sub2ind without its overhead
  isbg = bg(l2);
  srcE = [srcE; ok(isbg)];            %#ok<AGROW>  compact source indices
  dstE = [dstE; compact(l2(isbg))];   %#ok<AGROW>
end

lab = conncomp(graph(srcE, dstE, [], nb))';
isBorder = rr==1 | rr==szP(1) | cc==1 | cc==szP(2);
extLabels = unique(lab(isBorder));

ext = false(prod(szP),1);
ext(bgLin(ismember(lab, extLabels))) = true;
end

% ===========================================================================
function [POS, ID] = cells2posId(mask, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos)
% physical positions and (if present) ebsd ids of the raster cells in `mask`
%
% The forward flatten ij2slotP puts i in dim 1 (rows) and j in dim 2 (cols):
%   slot = (i-ijmin(1)+padding) + (j-ijmin(2)+padding)*szP(1) + 1
% so ind2sub returns rr = i-subscript, cc = j-subscript. Unflatten must match
% that order (rr -> i, cc -> j); swapping them shifts the reconstructed sites
% by one cell along an axis relative to the real sites.
[rr,cc] = ind2sub(szP, find(mask));
IJ  = [rr-1-padding+ijmin(1), cc-1-padding+ijmin(2)];

ID = nan(size(IJ,1),1);
inRange = IJ(:,1)>=ijmin(1) & IJ(:,1)<=ijmin(1)+ijsz(1)-1 & ...
          IJ(:,2)>=ijmin(2) & IJ(:,2)<=ijmin(2)+ijsz(2)-1;
slot = (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
ID(inRange) = ij2ebsd(slot(inRange));
ID(ID==0) = NaN;

% wherever a real ebsd row sits at this grid slot (e.g. a genuinely
% scanned but notIndexed pixel), its true measured position is exact -
% use it directly; only reconstruct where no such row exists (dummy ring,
% phase-subset gaps, filled small gaps)
hasReal = ~isnan(ID);
POS = reconstructPos(IJ);
POS(hasReal,:) = pos(ID(hasReal),:);
end