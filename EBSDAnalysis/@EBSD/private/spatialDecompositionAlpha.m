function out = spatialDecompositionAlpha(ebsd,varargin)
% grid-based spatial decomposition for grain reconstruction via a true
% (circumradius) alpha-complex, for square + hex grids
%
% Alternative to spatialDecompositionGrid.m's morphological-closing
% partition, selected by calcGrains via the 'delaunay' flag. Where
% spatialDecompositionGrid.m approximates the alpha shape by dilating/
% eroding the indexed raster with a disk structuring element,
% this file computes the actual Delaunay triangulation of the indexed
% sites and includes a triangle exactly when its circumradius is <=
% alpha*dxy (the classical, exact alpha-complex criterion; union rule -
% an edge/cell is filled if AT LEAST ONE incident triangle qualifies).
% Since this is exact rather than a raster approximation, it needs none
% of spatialDecompositionGrid.m's disk-approximation-correction logic
% (lateral companions for single-cell structuring-element tips,
% single-pixel-concavity filling).
%
% This file is intentionally self-contained (does not call into
% spatialDecompositionGrid.m or share its local subfunctions - MATLAB
% local functions aren't callable across files) and duplicates the
% generic lattice/padding/site-assembly scaffolding it needs. The one
% exception is the deformation aware position reconstruction, which both
% files now take from private/latticeModel.m - a private function IS
% callable from both, unlike a local one.
%
% Syntax
%   out = spatialDecompositionAlpha(ebsd,'alpha',2.2)
%
% Input
%  ebsd - gridified @EBSDsquare / @EBSDhex
%
% Options
%  alpha - alpha-complex radius in multiples of dxy (default 2.2). A
%          Delaunay triangle of the indexed sites is included (filled)
%          when its circumradius <= alpha*dxy; a gap/notch is bridged by
%          the alpha-complex exactly when some triangle spanning it
%          qualifies. Note this is a different quantity from
%          spatialDecompositionGrid's 'alpha' (a morphological closing-
%          radius multiplier) - the two are not meant to agree at a
%          shared alpha value.
%
% Output struct out - same contract as spatialDecompositionGrid.m
%  V        - nV × 2 Voronoi vertices
%  F        - nF × 2 vertex indices per boundary segment (1-based)
%  I_FD     - nF × nSites sparse incidence (segment × site), sites = grains
%  isNotIdx - nSites × 1 logical, which sites are notIndexed grains
%  site2id  - nSites × 1, ebsd linear index for indexed sites, NaN for
%             notIndexed sites that came from empty cells
%  ij       - nEbsd × 2 axial indices (debug)

alpha = get_option(varargin,'alpha',2.2);

% lattice / grid setup
g = ebsd.lattice;
A = g.A; stencil = g.stencil; dxy = g.dxy; ij = g.ij;
epsilon = dxy/100;

pos = [ebsd.pos.x(:), ebsd.pos.y(:)];
isIndexed = ebsd.isIndexed(:);

[ij2ebsd,~,ijmin,ijsz] = latticeLookup(ij);

% local model to reconstruct the position of grid cells with no real
% measurement - no longer duplicated from spatialDecompositionGrid.m
[reconstructPos,idealFun] = latticeModel(pos,ij,isIndexed,dxy);

% ---- alpha partition via a true circumradius alpha-complex -----------------
rAlpha = alpha*dxy;

% pad for the full diameter an included triangle can span, plus a safety margin
closeCells = ceil(2*rAlpha / min(vecnorm(A,2,1)));
padding = closeCells + 4;
szP     = ijsz + 2*padding;
ij2slotP = @(IJ) (IJ(:,1)-ijmin(1)+padding) + (IJ(:,2)-ijmin(2)+padding)*szP(1) + 1;

% padded binary mask of indexed pixels
isIndexedP = false(prod(szP),1);
isIndexedP(ij2slotP(ij(isIndexed,:))) = true;

closedP = alphaComplexMask(pos, isIndexed, ij, epsilon, rAlpha, ...
  szP, padding, ijmin, ijsz, ij2slotP, idealFun, reconstructPos);
closedP = closedP | isIndexedP;   % safety belt, as in spatialDecompositionGrid.m

% exteriorP = background connected to the padded border
exteriorP = floodFillBorder(~closedP, stencil, szP);

% guard: material must be strictly inside the padded raster, else the dummy
% ring is truncated at the border and the outer grains come out open
matP = reshape(~exteriorP, szP);
assert(~any([matP(1,:), matP(end,:), matP(:,1).', matP(:,end).']), ...
  'spatialDecompositionAlpha:padding', ...
  'material reaches the padded border - dummy ring truncated; increase padding');

% classification of every padded raster cell, as in spatialDecompositionGrid.m -
% without the concavity correction, the true alpha-complex has no discretization error
materialP = ~exteriorP;
bigHoleP  = ~closedP & ~exteriorP;

% one-cell exterior shell adjacent to the material
extBandP  = binaryDilate(materialP, stencil, szP) & exteriorP;

siteCellsP = isIndexedP | bigHoleP;

recessP = false(prod(szP),1);
hasDir  = false(prod(szP),size(stencil,1));
for s = 1:size(stencil,1)
  Ms = floor(rAlpha / norm(stencil(s,:)*A'));
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

% ---- assemble sites --------------------------------------------------------
idxSiteEbsd = find(isIndexed);
sitesIdx    = pos(idxSiteEbsd,:);

[holePos, holeId] = cells2posId(bigHoleP, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);
[bandPos, ~     ] = cells2posId(extBandP, szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);
niPos = [holePos; bandPos];
niId  = [holeId ; nan(size(bandPos,1),1)];
[dumPos, ~    ] = cells2posId(dummyP , szP, padding, ijmin, ijsz, reconstructPos, ij2ebsd, pos);

XY      = [sitesIdx; niPos; dumPos];
numReal = size(sitesIdx,1) + size(niPos,1);

isNotIdx = [false(size(sitesIdx,1),1); true(size(niPos,1),1)];
site2id  = [idxSiteEbsd; niId];

% ---- Voronoi -----------------------------------------------------------
[V,F,I_FD] = jcvoronoi2(double(XY),double(numReal), double(epsilon));

out = struct('V',V,'F',F,'I_FD',I_FD, ...
             'isNotIdx',isNotIdx,'site2id',site2id,'ij',ij);
end

% ===========================================================================
function closedP = alphaComplexMask(pos, isIndexed, ij, epsilon, rAlpha, ...
  szP, padding, ijmin, ijsz, ij2slotP, idealFun, reconstructPos)
% true circumradius alpha-complex, rasterized onto the padded (i,j) grid
%
% The indexed sites are triangulated together with a dummy ring beyond any
% alpha-included triangle, so no Voronoi edge is left unbounded. A triangle with
% circumradius <= rAlpha is filled, i.e. the convex hull of its incident real
% sites is rasterized - for a cocircular group the hull of the whole group.

idxIdx = find(isIndexed);
idxPos = pos(idxIdx,:);
nIdx = numel(idxIdx);

% dummy ring along the padded raster's perimeter, beyond any alpha-included triangle
iRange = (ijmin(1)-padding):(ijmin(1)+ijsz(1)-1+padding);
jRange = (ijmin(2)-padding):(ijmin(2)+ijsz(2)-1+padding);
ringIJ = [ ...
  [iRange.', repmat(jRange(1),  numel(iRange),1)]; ...
  [iRange.', repmat(jRange(end),numel(iRange),1)]; ...
  [repmat(iRange(1),  numel(jRange),1), jRange.']; ...
  [repmat(iRange(end),numel(jRange),1), jRange.'] ];
bnd = idealFun(unique(ringIJ,'rows'));

XYa = [idxPos; bnd];
[Va,Fa,I_FDa] = jcvoronoi2(double(XYa), double(nIdx), double(epsilon));

nnzPerEdge = full(sum(I_FDa,2));
pureEdge   = nnzPerEdge == 2;             % real-real edges (no dummy site)

touchesDummy = false(size(Va,1),1);
impureRows = find(~pureEdge);
touchesDummy(Fa(impureRows,1)) = true;
touchesDummy(Fa(impureRows,2)) = true;
pureVertex = ~touchesDummy;

% (vertex,site) incidences from pure edges only: both endpoints of a
% real-real edge are equidistant from both its sites
pureRows = find(pureEdge);
[er,ec] = find(I_FDa(pureRows,:));
er = pureRows(er);
vtxAll  = [Fa(er,1); Fa(er,2)];
siteAll = [ec; ec];

keep = pureVertex(vtxAll);
vtxAll = vtxAll(keep); siteAll = siteAll(keep);

if isempty(vtxAll)
  closedP = false(prod(szP),1);
  return
end

% circumradius per pure vertex, via any one associated site (all incident
% real sites are equidistant from the vertex by construction)
[uVtx,~,ib] = unique(vtxAll);
firstIdx = accumarray(ib, (1:numel(ib))', [], @min);
repSite  = siteAll(firstIdx);
rad = vecnorm(Va(uVtx,:) - idxPos(repSite,:), 2, 2);

included = rad <= rAlpha + epsilon;
incVtx = uVtx(included);

closedP = false(prod(szP),1);
if isempty(incVtx)
  return
end

% full site group per included vertex (its triangle, or its cocircular
% group's convex hull), deduplicated
isIncVtxMask = false(size(Va,1),1);
isIncVtxMask(incVtx) = true;
keep2 = isIncVtxMask(vtxAll);
vsPairs = unique([vtxAll(keep2), siteAll(keep2)],'rows');

[uV2,~,ig] = unique(vsPairs(:,1));
siteLists = accumarray(ig, vsPairs(:,2), [], @(x){x});

for k = 1:numel(uV2)
  siteList = siteLists{k};
  if numel(siteList) < 3, continue; end
  P = idxPos(siteList,:);

  % candidate grid cells: bounding box of this group's own sites (they are
  % indexed pixels with known (i,j)), expanded by one cell of slack
  candIJ = ij(idxIdx(siteList),:);
  ijLo = min(candIJ,[],1) - 1;
  ijHi = max(candIJ,[],1) + 1;
  [ci,cj] = ndgrid(ijLo(1):ijHi(1), ijLo(2):ijHi(2));
  candList = [ci(:) cj(:)];
  candXY = reconstructPos(candList);

  % point-in-convex-polygon: order P around its centroid, then test every edge
  c = mean(P,1);
  ang = atan2(P(:,2)-c(2), P(:,1)-c(1));
  [~,ord] = sort(ang);
  Pc = P(ord,:);
  nP = size(Pc,1);
  inside = true(size(candList,1),1);
  for e = 1:nP
    p1 = Pc(e,:); p2 = Pc(mod(e,nP)+1,:);
    edgeVec = p2 - p1;
    toCand = candXY - p1;
    crossVal = edgeVec(1)*toCand(:,2) - edgeVec(2)*toCand(:,1);
    inside = inside & crossVal >= -epsilon*max(norm(edgeVec),epsilon);
  end

  closedP(ij2slotP(candList(inside,:))) = true;
end

end

% ===========================================================================
function m2 = binaryDilate(m, offs, szP)
% binary morphological dilation of mask m (prod(szP) × 1 logical) by the
% structuring element `offs`, given as [di dj] axial (i,j) offsets.
% Duplicated verbatim from spatialDecompositionGrid.m (see there).
M  = reshape(m, szP);
M2 = false(szP);
n1 = szP(1); n2 = szP(2);
for o = 1:size(offs,1)
  di = offs(o,1); dj = offs(o,2);
  r = max(1,1+di):min(n1,n1+di);
  c = max(1,1+dj):min(n2,n2+dj);
  if isempty(r) || isempty(c), continue; end
  M2(r,c) = M2(r,c) | M(r-di, c-dj);
end
m2 = M2(:);
end

% ===========================================================================
function ext = floodFillBorder(bg, stencil, szP)
% flood fill: mark all background (bg) cells connected to the padded border.
% Duplicated verbatim from spatialDecompositionGrid.m (see there).
bgLin = find(bg);
nb = numel(bgLin);
compact = zeros(prod(szP),1); compact(bgLin) = 1:nb;
[rr,cc] = ind2sub(szP, bgLin);

srcE = []; dstE = [];
for s = 1:size(stencil,1)
  r2 = rr + stencil(s,1);  c2 = cc + stencil(s,2);
  ok = find(r2>=1 & r2<=szP(1) & c2>=1 & c2<=szP(2));
  l2 = r2(ok) + (c2(ok)-1)*szP(1);
  isbg = bg(l2);
  srcE = [srcE; ok(isbg)];            %#ok<AGROW>
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
% Duplicated verbatim from spatialDecompositionGrid.m (see there).
[rr,cc] = ind2sub(szP, find(mask));
IJ  = [rr-1-padding+ijmin(1), cc-1-padding+ijmin(2)];

ID = nan(size(IJ,1),1);
inRange = IJ(:,1)>=ijmin(1) & IJ(:,1)<=ijmin(1)+ijsz(1)-1 & ...
          IJ(:,2)>=ijmin(2) & IJ(:,2)<=ijmin(2)+ijsz(2)-1;
slot = (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
ID(inRange) = ij2ebsd(slot(inRange));
ID(ID==0) = NaN;

hasReal = ~isnan(ID);
POS = reconstructPos(IJ);
POS(hasReal,:) = pos(ID(hasReal),:);
end
