function out = spatialDecompositionGrid(ebsd,g,varargin)
% grid-based spatial decomposition for grain reconstruction (square + hex)
%
% Every gridified cell ends up classified as an indexed site, a kept dummy, or a
% notIndexed site; indexed and notIndexed sites become grains, dummies only bound
% the outer cells. Empty cells and input-notIndexed pixels are treated
% identically.
%
% Which cells without a measurement are filled is decided by a morphological
% closing of the indexed cells with a disk, or with 'delaunay' by the true
% circumradius alpha-complex of the indexed sites, see alphaComplexMask. All
% that follows the filled cells is the same for both.
%
% minPixel culling is not done here: the caller marks the pixels of undersized
% grains notIndexed and decomposes again.
%
% cells2posId (see there) places every site that has no real measurement -
% notIndexed holes, the exterior dummy ring bounding the map edge, filled
% small gaps - via a local deformation model (see latticeModel),
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
%   out = spatialDecompositionGrid(ebsd,ebsd.lattice,'alpha',1.5)
%   out = spatialDecompositionGrid(ebsd,ebsd.lattice,'alpha',2.2,'delaunay')
%
% Input
%  ebsd - gridified @EBSDsquare / @EBSDhex
%  g    - ebsd.lattice
%
% Options
%  alphaPore, alphaPocket, alphaCrack - the closing radius of the notIndexed
%             parts of that kind that the closing with alpha leaves open,
%             replacing alpha on their cells. alphaPore defaults to inf,
%             which fills the kind whole, alphaCrack to 0, which leaves it
%             entirely open, alphaPocket to alpha. A part is a pore
%             when one orientation holds 85 percent of its rim, a crack when
%             its Feret diameter squared is at least five times its area and
%             at least half of its boundary runs along grains, a void when it
%             touches the edge of the scan, a pocket otherwise; what lies
%             between two parts of a crack, joined to both by notIndexed
%             cells, is part of the crack
%  kinds    - a kind per pixel, categorical or code, replacing the computed
%             kind of every part it covers
%  alpha    - hole closing radius in multiples of dxy (default 3.1). Holes
%             narrower than 2*alpha*dxy are filled and vanish; wider holes are
%             preserved as measured (no growing into them). Single-pixel-wide
%             recesses (boundary notches, slit mouths) are always filled for
%             alpha >= 1, matching the alpha shape. With 'delaunay' the
%             alpha-complex radius (default 2.2): a Delaunay triangle of the
%             indexed sites is filled when its circumradius is at most
%             alpha*dxy - a different quantity, the two do not agree at a
%             shared value.
%
% Flags
%  delaunay - the alpha-complex instead of the closing
%  kindsOnly - return only the kinds and the parts, before the decomposition;
%             a pixel has the kind of the last part it was open in
%
% Output struct out with fields
%  V        - nV × 2 Voronoi vertices
%  F        - nF × 2 vertex indices per boundary segment (1-based)
%  I_FD     - nF × nSites sparse incidence (segment × site), sites = grains
%  isNotIdx - nSites × 1 logical, which sites are enclosed notIndexed holes
%  site2id  - nSites × 1, ebsd linear index for indexed sites, NaN for
%             notIndexed sites that came from empty cells
%  ij       - nEbsd × 2 axial indices (debug)
%  inFill   - @(p) > 0 inside the filled cells, < 0 outside, [] without any
%  fill     - the filled cells as a mask over the padded raster
%  fillTest - @(mask) the inFill of the cells of a mask over the raster
%  site2cell - the raster cell of every site
%  cell2pos - @(c) position of the raster cell c = [i j], also between the cells
%  with kindsOnly: kinds, a categorical per pixel (pore, pocket, crack, void,
%  speck, indexed), and parts, a table of the thick parts with their features

isDelaunay = check_option(varargin,'delaunay');
alpha = get_option(varargin,'alpha',2.2*isDelaunay + 3.1*~isDelaunay);

A = g.A; stencil = double(g.stencil); dxy = g.dxy; ij = double(g.ij);
epsilon = dxy/100;

pos = [ebsd.pos.x(:), ebsd.pos.y(:)];
isIndexed = ebsd.isIndexed(:);

% ij2ebsd(slot) is the ebsd index of a lattice slot, 0 if not contained in the map
[ij2ebsd,~,ijmin,ijsz] = latticeLookup(ij);

% local model to reconstruct the position of grid cells with no real
% measurement (notIndexed holes, the dummy/band ring, filled small gaps)
[reconstructPos,idealFun,isRigid] = latticeModel(pos,ij,isIndexed,A);

% ---- alpha partition -------------------------------------------------------
% Work on a padded raster of the (i,j) grid. All operations below are binary
% 2D morphology, linearised over the padded raster for speed.

rClose  = alpha*dxy;                            % closing radius: fills holes of
                                                % diameter < 2*rClose = 2*alpha*dxy
% Padding must leave room for (i) the closing, which can push the material
% outward by up to rClose before the erosion, or an alpha-complex triangle,
% up to 2*rClose across, and (ii) at least one exterior cell beyond that for
% the dummy ring to sit in. If the material ever reaches the padded border,
% the flood fill cannot wrap around it, no dummies are placed there, and the
% outer grains come out open.
% pores, pockets and cracks may close with a radius of their own
alphaK = [get_option(varargin,'alphaPore',inf), ...
          get_option(varargin,'alphaPocket',alpha), get_option(varargin,'alphaCrack',0)];
rMax = max([alpha, alphaK(isfinite(alphaK))])*dxy;
closeCells = ceil((1 + isDelaunay)*rMax / min(vecnorm(A,2,1)));
padding = closeCells + 4;   % closing reach + band (1) + pushed band (1) + dummy ring (1) + safety (1)
szP     = ijsz + 2*padding;
ij2slotP = @(IJ) (IJ(:,1)-ijmin(1)+padding) + (IJ(:,2)-ijmin(2)+padding)*szP(1) + 1;

% padded binary mask of indexed pixels
isIndexedP = false(prod(szP),1);
isIndexedP(ij2slotP(ij(isIndexed,:))) = true;
% imagesc(reshape(isIndexedP,szP)), axis equal tight

% the scan footprint, the convex hull of the indexed pixels: beyond it the
% material counts as present during the erosion, so that the map edge is no
% boundary the closing erodes from
inScanP = true(prod(szP),1);
try %#ok<TRYNC>
  inScanP = inConvexHull(ij(isIndexed,:), ijmin - padding - 1, szP);
end

if isDelaunay
  % the smallest circumradius of a filled triangle covering each cell, inf where none
  rMin = alphaComplexMask(pos, isIndexed, ij, epsilon, rMax, ...
    szP, padding, ijmin, ijsz, idealFun, reconstructPos, isIndexedP);
  closedP = rMin <= rClose + epsilon | isIndexedP;
  isOpen = @(x,r) rMin(x) > r*dxy + epsilon;
else
  closedP = closeAt(isIndexedP, inScanP, alpha, dxy, A, stencil, szP);
  isOpen = @(x,r) ~closedAt(x, isIndexedP, inScanP, diskOffsets(r*dxy, A, stencil), szP);
end

% the closing radius of a cell is that of the kind of its notIndexed part:
% pores, pockets and cracks each close with their own radius, which replaces
% alpha on their cells - below alpha it reopens what the closing filled. A
% closing that cuts a part apart leaves pieces of another kind, so the parts
% left open are classified again until nothing changes
byKindP = false(prod(szP),1);
kindsOnly = check_option(varargin,'kindsOnly');
if any(alphaK ~= alpha) || kindsOnly
  ebsdP = zeros(prod(szP),1); ebsdP(ij2slotP(ij)) = 1:size(ij,1);
  gbc = grainBoundaryCriterion.byOptions(varargin{:});
  K = zeros(prod(szP),1); parts = []; closed0 = [];
  while ~isequal(closedP,closed0)
    closed0 = closedP;
    [kindP,pp,labP] = kindOfParts(closedP, isIndexedP, inScanP, ebsdP, ebsd, gbc, ...
      kindCode(get_option(varargin,'kinds',[])), stencil, szP, A);
    parts = [parts; pp(unique(labP(kindP > 0 & kindP ~= K & labP > 0)),:)]; %#ok<AGROW>
    K(kindP > 0) = kindP(kindP > 0);
    for k = find(alphaK ~= alpha)
      x = find(kindP == k);
      if isDelaunay
        c = rMin(x) <= alphaK(k)*dxy + epsilon;
      elseif isinf(alphaK(k))
        c = true(size(x));
      else
        c = closedAt(x, isIndexedP, inScanP, diskOffsets(alphaK(k)*dxy, A, stencil), szP);
      end
      byKindP(x(c)) = true;
      closedP(x) = c;
    end
  end
  if kindsOnly
    K(~inScanP & ~isIndexedP) = 4; K(K == 0) = 5; K(isIndexedP) = 6;
    parts.id = (1:height(parts)).';
    out = struct('kinds',reshape(kindName(K(ij2slotP(ij))),size(ebsd.phaseId)),'parts',parts);
    return
  end
end

% exteriorP = background connected to the padded border. This is a flood fill
% (morphological reconstruction of the border marker under the mask ~closedP),
% here computed as connected components of ~closedP with border-touching label.
exteriorP = floodFillBorder(~closedP, stencil, szP);   % 2D flood fill

% a hole joined to the outside by a filled notIndexed path of at most 2*alpha
% steps stays joined, through what the largest closing that keeps it joined leaves open
nSteps = 2*ceil(alpha);
rs = [alpha-1:-1:1, 0]; openAt = cell(size(rs));   % what every closing below alpha leaves open
ext0 = [];
while ~isequal(exteriorP,ext0)   % a hole that joined the outside can join the next
  ext0 = exteriorP;
  f = closedP & ~isIndexedP & ~byKindP;
  dExt = geoDist(exteriorP, f, stencil, szP, nSteps);
  [dHole,hole] = geoDist(~closedP & ~exteriorP, f & dExt <= nSteps, stencil, szP, nSteps);
  corridor = find(f & dExt + dHole <= nSteps);
  for q = 1:numel(rs)
    corridor = corridor(closedP(corridor) & ~exteriorP(hole(corridor)));
    if isempty(corridor), break; end
    if isempty(openAt{q}), openAt{q} = isOpen((1:prod(szP)).',rs(q)); end
    x = corridor(openAt{q}(corridor));
    closedP(x) = false;
    % the opened cells next to the outside take their holes with them
    x = x(any(reshape(exteriorP(x + (stencil(:,1) + stencil(:,2)*szP(1)).'),numel(x),[]),2));
    if ~isempty(x)
      exteriorP = exteriorP | geoDist(x, ~closedP & ~exteriorP, stencil, szP, prod(szP)) < inf;
    end
  end
end
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
b = find(extBandP);
hasDir = false(numel(b),size(stencil,1));
for s = 1:size(stencil,1)
  Ms = floor(rClose / norm(stencil(s,:)*A'));
  hasDir(:,s) = any(materialP(b + (1:Ms)*(stencil(s,:)*[1; szP(1)])),2);
end
recessP = false(prod(szP),1);
for s = 1:size(stencil,1)
  [~,o] = ismember(-stencil(s,:),stencil,'rows');
  if o > s, recessP(b) = recessP(b) | (hasDir(:,s) & hasDir(:,o)); end
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

isNotIdx = [false(size(sitesIdx,1),1); true(size(holePos,1),1); false(size(bandPos,1),1)];
site2id  = [idxSiteEbsd; niId];

% ---- Voronoi -----------------------------------------------------------
% a cell reaches as far as the widest filled region: the closing bounds that
% by alpha, a kind's radius does not, so it is measured
fillP = closedP & ~isIndexedP;
d = geoDist(~fillP, fillP, stencil, szP, prod(szP)); reach = max([0; d(fillP)]);
slot = [ij2slotP(ij(idxSiteEbsd,:)); find(bigHoleP); find(extBandP); find(dummyP)];
[V,F,I_FD] = latticeVoronoi(XY,slot,szP,A,numReal,epsilon,max(alpha,reach));

% inFill(p) > 0 inside the filled cells, < 0 outside: the distance to the
% nearest other cell centre minus the one to the nearest filled. On a rigid
% grid both are among the four lattice points around p, otherwise searched
% among the filled cells and the others within two cells of them
if isRigid
  p0 = reconstructPos([0 0]);
  M = reconstructPos([1 0; 0 1]) - p0;
  fillTest = @(f) @(p) rigidInFill(p,p0,M,f(:),szP,ijmin-padding-1);
else
  fillTest = @(f) scatteredInFill(f(:),stencil,szP,padding,ijmin,ijsz,reconstructPos,ij2ebsd,pos);
end
inFill = [];
if any(fillP), inFill = fillTest(fillP); end

out = struct('V',V,'F',F,'I_FD',I_FD, ...
             'isNotIdx',isNotIdx,'site2id',site2id,'ij',ij,'dxy',dxy,'epsilon',epsilon, ...
             'inFill',inFill,'fill',reshape(fillP,szP),'fillTest',fillTest,'site2cell',slot, ...
             'cell2pos',@(c) reconstructPos(c + (ijmin - padding - 1)));
end

% ===========================================================================
function closedP = closeAt(isIndexedP, inScanP, alpha, dxy, A, stencil, szP)
% closing of the indexed cells by the disk of radius alpha*dxy
diskOffs = diskOffsets(alpha*dxy, A, stencil);

% morphological CLOSING of the indexed set by the disk:
%   closedP = erode(dilate(isIndexedP)) , erosion done as the complement of the
%   dilation of the complement (De Morgan). Fills holes/slits narrower than
%   2*alpha*dxy, preserves wider holes, and is extensive (never drops an
%   indexed cell). The final "| isIndexedP" is a safety belt against discretisation.
dilatedP = binaryDilate(isIndexedP, diskOffs, szP) | ~inScanP;  % 2D binary dilation
closedP  = ~binaryDilate(~dilatedP, diskOffs, szP) & inScanP;   % 2D binary erosion
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
end

% ===========================================================================
function offs = diskOffsets(rClose, A, stencil)
% the disk of radius rClose as (i,j) offsets
wi = ceil(rClose / vecnorm(A(:,1))) + 1;
wj = ceil(rClose / vecnorm(A(:,2))) + 1;
[di,dj] = meshgrid(-wi:wi, -wj:wj);
dxyDisk = [di(:) dj(:)] * A';                   % physical displacement of each offset
inDisk  = sum(dxyDisk.^2,2) <= rClose^2;
offs = [di(inDisk) dj(inDisk)];
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
offs = unique([offs; comp],'rows');
end

% ===========================================================================
function c = closedAt(x, isIndexedP, inScanP, offs, szP)
% the closing of the indexed cells by offs, at the raster cells x alone, over the box the two dilations read
c = false(numel(x),1); if isempty(x), return, end
[i,j] = ind2sub(szP,x(:)); w = 2*max(abs(offs(:)));
r = max(min(i)-w,1):min(max(i)+w,szP(1)); s = max(min(j)-w,1):min(max(j)+w,szP(2));
P = reshape(isIndexedP,szP); P = P(r,s); Q = reshape(inScanP,szP); Q = Q(r,s); sz = size(P);
d = binaryDilate(P(:),offs,sz) | ~Q(:);
c = ~binaryDilate(~d,offs,sz) & Q(:) | P(:);
c = c(i-r(1)+1 + (j-s(1))*sz(1));
end

% ===========================================================================
function inFill = scatteredInFill(fillP,stencil,szP,padding,ijmin,ijsz,reconstructPos,ij2ebsd,pos)
% inFill on a distorted grid, searched among the filled cells and the others within two cells of them
ringP = binaryDilate(binaryDilate(fillP, stencil, szP), stencil, szP) & ~fillP;
fXY = cells2posId(fillP, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);
oXY = cells2posId(ringP, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);
nearF = nearestId(fXY);
nearO = nearestId(oXY);
inFill = @(p) vecnorm(p - oXY(nearO(p),:),2,2) - vecnorm(p - fXY(nearF(p),:),2,2);
end

function d = rigidInFill(p,p0,M,fillP,szP,ij0)
% inFill on the rigid grid p0 + [i j]*M from the four lattice points around p,
% +-Inf where they are all of one kind

q = p - p0;
c = floor(q / M);
rc = c - ij0;
l = rc(:,1) + (rc(:,2)-1)*szP(1);
l(~all(rc >= 1 & rc < szP,2)) = 1;   % off the raster, among the padding
dF = inf(size(p,1),1); dO = dF;
for k = [0 0; 1 0; 0 1; 1 1].'
  dist = vecnorm(q - (c + k.')*M,2,2);
  isF = fillP(l + k(1) + k(2)*szP(1));
  dF = min(dF,dist./isF);
  dO = min(dO,dist./~isF);
end
d = dO - dF;
end

% ===========================================================================
function m2 = binaryDilate(m, offs, szP)
% binary morphological dilation of mask m (prod(szP) × 1 logical) by the
% structuring element `offs`, given as [di dj] axial (i,j) offsets. Consistent
% with the flatten ij2slotP, i is the row (dim 1) and j is the column (dim 2),
% so an offset's 1st component moves the row and its 2nd component the column.
%
% A run of offsets with one di and consecutive dj is covered by two windows of
% 2^k cells of a row, taken from a table built by doubling
M = reshape(m, szP); n1 = szP(1); n2 = szP(2);

% a disk, whose row di is the interval |dj| <= h(di) with h falling in |di|,
% dilates by the distance g to the nearest cell along every row: a cell of
% row k with g <= h(t) covers the rows k-t..k+t
[d,~,k] = unique(offs(:,1));
h = accumarray(k,offs(:,2),[],@max);
if numel(d) > 8 && isequal(d,(-d(end):d(end))') && isequal(h,flip(h)) && ...
    isequal(accumarray(k,offs(:,2),[],@min),-h) && sum(2*h+1) == size(unique(offs,'rows'),1) && ...
    issorted(h(d >= 0),'descend')
  w = sum(h(d >= 0) >= 0:h(d == 0)) - 1;  % w(g+1) = the most rows a cell at distance g covers
  J = repmat(1:n2,n1,1);
  L = J; L(~M) = -inf; R = J; R(~M) = inf;
  g = min(J - cummax(L,2), cummin(R,2,'reverse') - J);
  t = -inf(szP); ok = g <= h(d == 0); t(ok) = w(g(ok)+1);
  I = (1:n1)';
  m2 = reshape(cummax(I + t) >= I | cummin(I - t,'reverse') <= I,[],1);
  return
end

offs = sortrows(offs); W = max(abs(offs(:,2)));
s = find([true; diff(offs(:,1)) ~= 0 | diff(offs(:,2)) ~= 1]);
e = [s(2:end)-1; size(offs,1)];
H = {[false(n1,W), M, false(n1,W)]};   % H{k+1}(:,j) = any of the 2^k cells from j on of a padded row
M2 = false(szP);
for q = 1:numel(s)
  di = offs(s(q),1); a = offs(s(q),2); b = offs(e(q),2);
  k = floor(log2(b-a+1));
  while numel(H) <= k
    p = 2^(numel(H)-1); h = H{end};
    h(:,1:end-p) = h(:,1:end-p) | h(:,1+p:end); H{end+1} = h; %#ok<AGROW>
  end
  r = max(1,1+di):min(n1,n1+di);                % target rows with valid source
  if isempty(r), continue; end
  M2(r,:) = M2(r,:) | H{k+1}(r-di,W-b+(1:n2)) | H{k+1}(r-di,W-a-2^k+1+(1:n2));
end
m2 = M2(:);
end

% ===========================================================================
function cnt = stencilCount(m, offs, szP)
% number of foreground cells of m (prod(szP) × 1 logical) among the stencil
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
% the cells of bg connected to the border of the raster
lab = reshape(components(bg, stencil, szP), szP);
ext = ismember(lab, [lab([1 end],:) lab(:,[1 end]).']) & lab > 0;
ext = ext(:);
end

% ===========================================================================
function lab = components(m, stencil, szP)
% connected components of the cells of m over the stencil, numbered in the
% order of their first cell, 0 off m; the runs along the rows are the nodes,
% joined where a run or its neighbour starts
n1 = szP(1);
s = m & ~[false; m(1:end-1)]; s(1:n1:end) = m(1:n1:end);
run = cumsum(s);
x = find(m); i = mod(x-1,n1);
[a,b] = deal([]);
for o = stencil(stencil(:,2) > 0,:).'
  y = x + o(1) + o(2)*n1;
  ok = i + o(1) >= 0 & i + o(1) < n1 & y <= numel(m);
  ok(ok) = m(y(ok)) & (s(x(ok)) | s(y(ok)));
  a = [a; run(x(ok))]; b = [b; run(y(ok))]; %#ok<AGROW>
end
c = conncomp(graph(a,b,[],run(end))).';
[~,~,c] = unique(c,'stable');
lab = zeros(size(m)); lab(x) = c(run(x));
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

% take the measured position wherever a real ebsd row sits at this slot
hasReal = ~isnan(ID);
POS = reconstructPos(IJ);
POS(hasReal,:) = pos(ID(hasReal),:);
end


% -------------------------------------------------------------------------
function inside = inConvexHull(ij, offset, sz)
% which cells (i,j) = (row,col) + offset of a raster of size sz lie in the
% convex hull of the integer points ij: every row meets it in one interval

% the hull of the first and the last point of every row
i0 = min(ij(:,1)) - 1;
lo = accumarray(ij(:,1) - i0, ij(:,2), [], @min, nan);
hi = accumarray(ij(:,1) - i0, ij(:,2), [], @max, nan);
r = find(~isnan(lo));
ij = [r + i0 lo(r); r + i0 hi(r)];
h = convhull(ij(:,1),ij(:,2));
a = ij(h(1:end-1),:); b = ij(h(2:end),:);
rows = cell(size(a,1),1); cols = rows;
for k = 1:size(a,1)
  if a(k,1) == b(k,1)
    rows{k} = [a(k,1); a(k,1)]; cols{k} = [a(k,2); b(k,2)];
  else
    rows{k} = (min(a(k,1),b(k,1)):max(a(k,1),b(k,1))).';
    cols{k} = a(k,2) + (rows{k} - a(k,1)) * (b(k,2)-a(k,2)) / (b(k,1)-a(k,1));
  end
end
r = vertcat(rows{:}) - offset(1); c = vertcat(cols{:});
lo = accumarray(r, c, [sz(1) 1], @min, inf);
hi = accumarray(r, c, [sz(1) 1], @max, -inf);
j = offset(2) + (1:sz(2));
inside = reshape(j >= lo - 1e-9 & j <= hi + 1e-9,[],1);

end


% ===========================================================================
function [kindP,parts,labP] = kindOfParts(closedP, isIndexedP, inScanP, ebsdP, ebsd, gbc, override, stencil, szP, A)
% kind of every cell of the notIndexed parts the closing leaves open:
% 1 pore, 2 pocket, 3 crack (long, and walled by grains on at least half of
% its boundary), 4 void, 0 elsewhere; override is a code per ebsd pixel that
% replaces the computed kind of its part; labP is the part of every cell
open = ~closedP & inScanP;
o = stencil(:,1) + stencil(:,2)*szP(1);
labP = components(open, stencil, szP);
nP = max(labP);
area = accumarray(labP(open),1,[nP 1]);

% the cells of a part next to one that is not open carry its border contact, Feret diameter and contacts
x = find(open & binaryDilate(~open, stencil, szP));
lab = labP(x);
nX = accumarray(lab,1,[nP 1]);
touch = binaryDilate(~inScanP, stencil, szP);
border = accumarray(lab,touch(x),[nP 1]) > 0;
[r,c] = ind2sub(szP,x);
xy = [r c]*A';
feret = zeros(nP,1);
[~,ord] = sort(lab); last = cumsum(nX);
for p = find(area >= 3).'
  q = xy(ord(last(p)-nX(p)+1:last(p)),:);
  try q = q(convhull(q(:,1),q(:,2)),:); end %#ok<TRYNC>
  feret(p) = max(vecnorm(permute(q,[1 3 2]) - permute(q,[3 1 2]),2,3),[],'all');
end
elong = feret.^2 ./ (area*abs(det(A)));

% the cells around every part that are not open, one contact per part and cell:
% the notIndexed ones, the outside and the filled cells, are its gap, the indexed its rim
y = reshape(x + o.',[],1); p = repmat(lab,numel(o),1); m = ~open(y);
ct = unique([p(m) y(m)],'rows');
isRim = isIndexedP(ct(:,2));
gap = accumarray(ct(~isRim,1),1,[nP 1]);
ct = ct(isRim,:);
nC = size(ct,1);
key = ct(:,1) + nP*ct(:,2);

% adjacent rim cells of one part, joined where the criterion connects them
[a,b] = deal([]);
for s = o.'
  [tf,j] = ismember(ct(:,1) + nP*(ct(:,2)+s), key);
  a = [a; find(tf)]; b = [b; j(tf)]; %#ok<AGROW>
end
m = a < b; a = a(m); b = b(m);
same = connects(ct(a,2),ct(b,2));
cl = conncomp(graph(a(same),b(same),[],nC)).';

% rim pieces of one part joined once more when their first cells connect,
% except on the border, where a part is a void whatever its rim
[~,first,piece] = unique(cl);
I = sparse(1:numel(first),ct(first,1),~border(ct(first,1)),numel(first),nP);
[a,b] = find(triu(I*I',1));
same = connects(ct(first(a),2),ct(first(b),2));
cl = conncomp(graph(a(same),b(same),[],numel(first))).';
cl = cl(piece);
rim = accumarray(ct(:,1),1,[nP 1]);
piece = accumarray(cl,1);
share = accumarray(ct(:,1),piece(cl),[nP 1],@max,0) ./ max(rim,1);

kind = 2*ones(nP,1);
kind(share >= 0.85) = 1;
kind(border) = 4;
kind(elong >= 5 & gap <= rim) = 3;

if ~isempty(override)
  x = find(open & ebsdP > 0); k = reshape(override(ebsdP(x)),[],1);
  k = accumarray(labP(x(k > 0)),k(k > 0),[nP 1],@mode,0);
  kind(k > 0) = k(k > 0);
end

% what lies between two parts of a crack is part of it, since the closing
% cuts a crack where it narrows. The parts and the connected pieces of
% filled cells are the nodes of a graph, a contact is an edge; pruning the
% leaves that are no crack part leaves the nodes between crack parts
kindP = zeros(prod(szP),1);
if any(kind == 3)
  thin = ~isIndexedP & inScanP & closedP;
  ct = components(thin, stencil, szP); thin = find(thin); ct = ct(thin);
  nT = max([ct;0]);
  [a,b] = deal([]);
  for s = o.'
    z = thin + s; ok = labP(z) > 0;
    a = [a; nP + ct(ok)]; b = [b; labP(z(ok))]; %#ok<AGROW>
  end
  E = sparse(a,b,1,nP+nT,nP+nT) > 0; E = E | E';
  isCrack = [kind == 3; false(nT,1)];
  keep = true(nP+nT,1);
  while true
    leaf = keep & ~isCrack & E*keep <= 1;
    if ~any(leaf), break; end
    keep(leaf) = false;
  end
  comp = conncomp(graph(E(keep,keep))).';
  between = false(nP+nT,1);
  between(keep) = ismember(comp, comp(isCrack(keep))) & ~isCrack(keep);
  kind(between(1:nP)) = 3;
  kindP(thin(between(nP + ct))) = 3;
end
kindP(open) = kind(labP(open));
parts = table((1:nP).',kindName(kind),area,feret,elong,border,gap,rim,share, ...
  'VariableNames',{'id','kind','area','feret','elong','border','gap','rim','share'});

  function tf = connects(i,j)
    % the criterion on the pixels of two raster cells
    tf = gbc.eval(ebsd,ebsdP(i),ebsdP(j)) > 0;
  end
end

% ===========================================================================
function c = kindName(k)
% the kinds as a categorical, from their codes
names = ["pore" "pocket" "crack" "void" "speck" "indexed"];
c = reshape(categorical(names(k),names),size(k));
end

% ===========================================================================
function k = kindCode(c)
% the codes of the kinds 1 pore, 2 pocket, 3 crack, 4 void, 0 for the rest
if isempty(c) || isnumeric(c), k = c; return; end
[~,k] = ismember(string(c(:)),["pore" "pocket" "crack" "void"]);
end
