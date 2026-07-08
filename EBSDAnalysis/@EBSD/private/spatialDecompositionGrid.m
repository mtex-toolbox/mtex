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
% Syntax
%   out = spatialDecompositionGrid(ebsd,'alpha',1.5)
%
% Input
%  ebsd - gridified @EBSDsquare / @EBSDhex
%
% Options
%  alpha    - hole closing radius in multiples of dxy (default 1.5). Holes
%             narrower than 2*alpha*dxy are filled and vanish; wider holes are
%             preserved as measured (no growing into them).
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
[A,stencil,dxy] = latticeBasis(ebsd.unitCell);
epsilon = dxy/100;

pos    = [ebsd.pos.x(:), ebsd.pos.y(:)];
origin = min(pos,[],1);
ij     = round((pos - origin) / A');          % axial indices, n x 2

nE       = size(pos,1);
isIndexed = ebsd.isIndexed(:);

% fast neighbour lookup
% ij2ebsd(ij2slot([i j])) is the ebsd index / 0 if not contained in the map
ijmin = min(ij,[],1);
ijsz  = max(ij,[],1) - ijmin + 1;               % raster size in (i,j)
ij2slot = @(IJ) (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
ij2ebsd = zeros(prod(ijsz),1);
ij2ebsd(ij2slot(ij)) = 1:nE;                    % 0 = empty cell

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
padding = closeCells + 3;   % closing reach + exterior band (1) + dummy ring (1) + safety (1)
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
% dummy ring one cell beyond the band (bounds the band cells)
dummyP    = binaryDilate(materialP | extBandP, stencil, szP) & exteriorP & ~extBandP;
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
[holePos, holeId] = cells2posId(bigHoleP, szP, padding, ijmin, ijsz, A, origin, ij2ebsd);
[bandPos, ~     ] = cells2posId(extBandP, szP, padding, ijmin, ijsz, A, origin, ij2ebsd);
niPos = [holePos; bandPos];
niId  = [holeId ; nan(size(bandPos,1),1)];
% dummy sites (outer shell) - never carry an id
[dumPos, ~    ] = cells2posId(dummyP , szP, padding, ijmin, ijsz, A, origin, ij2ebsd);

% real (=grain) sites first: indexed then notIndexed; dummies last
XY      = [sitesIdx; niPos; dumPos];
numReal = size(sitesIdx,1) + size(niPos,1);

isNotIdx = [false(size(sitesIdx,1),1); true(size(niPos,1),1)];
site2id  = [idxSiteEbsd; niId];

% ---- Voronoi ---------------------------------------------------------------
[V,F,I_FD] = jcvoronoi2_mex(double(XY),double(numReal), epsilon);

out = struct('V',V,'F',F,'I_FD',I_FD, ...
             'isNotIdx',isNotIdx,'site2id',site2id,'ij',ij);
end

% ===========================================================================
function m2 = binaryDilate(m, offs, szP)
% binary morphological dilation of mask m (prod(szP) x 1 logical) by the
% structuring element `offs`, given as [di dj] axial (i,j) offsets. Consistent
% with the flatten ij2slotP, i is the row (dim 1) and j is the column (dim 2),
% so an offset's 1st component moves the row and its 2nd component the column.
% Linearised: scatter every foreground cell to all offset positions.
[rr,cc] = ind2sub(szP, find(m));
m2 = false(prod(szP),1);
for o = 1:size(offs,1)
  r = rr + offs(o,1);  c = cc + offs(o,2);      % i-step -> row, j-step -> col
  ok = r>=1 & r<=szP(1) & c>=1 & c<=szP(2);
  m2(sub2ind(szP, r(ok), c(ok))) = true;
end
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
  l2 = sub2ind(szP, r2(ok), c2(ok));
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
function [POS, ID] = cells2posId(mask, szP, padding, ijmin, ijsz, A, origin, ij2ebsd)
% physical positions and (if present) ebsd ids of the raster cells in `mask`
%
% The forward flatten ij2slotP puts i in dim 1 (rows) and j in dim 2 (cols):
%   slot = (i-ijmin(1)+padding) + (j-ijmin(2)+padding)*szP(1) + 1
% so ind2sub returns rr = i-subscript, cc = j-subscript. Unflatten must match
% that order (rr -> i, cc -> j); swapping them shifts the reconstructed sites
% by one cell along an axis relative to the real sites.
[rr,cc] = ind2sub(szP, find(mask));
IJ  = [rr-1-padding+ijmin(1), cc-1-padding+ijmin(2)];
POS = IJ*A' + origin;

ID = nan(size(IJ,1),1);
inRange = IJ(:,1)>=ijmin(1) & IJ(:,1)<=ijmin(1)+ijsz(1)-1 & ...
          IJ(:,2)>=ijmin(2) & IJ(:,2)<=ijmin(2)+ijsz(2)-1;
slot = (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
ID(inRange) = ij2ebsd(slot(inRange));
ID(ID==0) = NaN;
end