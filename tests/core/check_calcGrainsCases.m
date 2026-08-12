function check_calcGrainsCases
% fast correctness suite for EBSD.calcGrains, covering grid type x
% transform combinations plus the removeQuadruplePoints option, using only
% small synthetic maps (runs in well under a second).
%
% Consolidates the small-map regression cases that used to live in
% check_calcGrainsTransform and check_calcGrainsQuadruplePoints. Real,
% large reference datasets (forsterite/copper/steel) are NOT part of this
% suite - they live in check_grainReconstructionBenchmark, which is a
% manual/opt-in performance benchmark meant to be run after a feature is
% finished, not as part of routine testing.
%
% See also
% check_grainReconstructionBenchmark

cs = crystalSymmetry('1','mineral','test');
thr = 5*degree;

%% square grid: plain reconstruction + transform/rotate commutation
%
% covers a bug in spatialDecompositionGrid's private cells2posId helper:
% it used to place the synthetic position of every grid cell with no real
% measurement (notIndexed holes, the exterior dummy ring, filled small
% gaps) via a single RIGID affine reconstruction ij*A' + origin, instead of
% the true measured position (when a real ebsd row exists there) or a
% locally interpolated deformation model (otherwise). A non-rigid
% distortion (trapezoidal stage drift) exposes this: calcGrains on a
% transformed map must agree with transforming the grains reconstructed
% from the untransformed map (see grain2d/transform). A rigid rotation is
% checked the same way (see grain2d/rotate) since it stresses a rotated,
% non-axis-aligned grid instead of a distorted one.

ebsdSq = buildSquareBlockGrid(cs, 6, 4, ...
  orientation.byAxisAngle(zvector,(1:16)*7*degree,cs));
grains0Sq = calcGrains(ebsdSq,'threshold',thr);

if length(grains0Sq) ~= 16
  error('square grid: expected 16 grains, got %d', length(grains0Sq));
end

checkTransformCommutation(ebsdSq, grains0Sq, thr, 'square, transformed');
checkRotateCommutation(ebsdSq, grains0Sq, thr, 'square, rotated');

%% hex grid: plain reconstruction + transform/rotate commutation
%
% same commutation checks as above, on a hexagonal grid built by
% gridify-ing an unstructured triangular-lattice point set (calcUnitCell
% auto-detects the hex unit cell from the point spacing).

ebsdHex = buildHexBlockGrid(cs, 5, 4, ...
  orientation.byAxisAngle(zvector,(1:16)*7*degree,cs));
grains0Hex = calcGrains(ebsdHex,'threshold',thr);

if length(grains0Hex) ~= 16
  error('hex grid: expected 16 grains, got %d', length(grains0Hex));
end

checkTransformCommutation(ebsdHex, grains0Hex, thr, 'hex, transformed');
checkRotateCommutation(ebsdHex, grains0Hex, thr, 'hex, rotated');

%% 'delaunay' flag: true alpha-complex backend (spatialDecompositionAlpha)
%
% same square/hex grids as above, reconstructed with the 'delaunay' flag
% instead of the default morphological-closing backend. Grids here are
% perfectly regular, so most Voronoi vertices are exactly cocircular
% (every 2x2 block of the square grid, and the hex grid's own triangular
% symmetry) - this exercises the alpha-complex's handling of cocircular
% site groups (rasterizing the whole convex hull rather than one arbitrary
% triangulation), not just the generic non-degenerate case.

grains0SqD = calcGrains(ebsdSq,'threshold',thr,'delaunay');
if length(grains0SqD) ~= 16
  error('square grid, delaunay: expected 16 grains, got %d', length(grains0SqD));
end
checkTransformCommutation2(ebsdSq, grains0SqD, thr, 'square, delaunay, transformed', 'delaunay');

grains0HexD = calcGrains(ebsdHex,'threshold',thr,'delaunay');
if length(grains0HexD) ~= 16
  error('hex grid, delaunay: expected 16 grains, got %d', length(grains0HexD));
end
checkTransformCommutation2(ebsdHex, grains0HexD, thr, 'hex, delaunay, transformed', 'delaunay');

%% gbcFMC: single precision rotations and coordinates
%
% regression test for gbcFMC dying on any map stored in SINGLE - which
% mtexdata martensite is, as are the .ang/.ctf imports generally:
%
%   Error using sparse. Third input must be double or logical.
%
% quaternion/double only stacks the four components, it does not convert
% them, so single propagated from ebsd.rotations through the neighbour
% misorientations into the edge weights, and sparse() rejected them. Both
% the orientation and the position path are forced to single here, since
% each reaches a different consumer (sparse for the weights, accumarray for
% the moment sums in part6InterpWeights).

ebsdSgl = buildSquareBlockGrid(cs, 6, 4, ...
  orientation.byAxisAngle(zvector,(1:16)*7*degree,cs));

rSgl = ebsdSgl.rotations;
ebsdSgl.rotations = rotation(quaternion( ...
  single(rSgl.a),single(rSgl.b),single(rSgl.c),single(rSgl.d)));
ebsdSgl.pos = vector3d(single(ebsdSgl.pos.x), ...
  single(ebsdSgl.pos.y),single(ebsdSgl.pos.z));

if ~isa(ebsdSgl.rotations.a,'single') || ~isa(ebsdSgl.x,'single')
  error('single precision test map did not stay single - test is vacuous');
end

grainsSgl = calcGrains(ebsdSgl,gbcFMC(3),'minPixel',1);
if length(grainsSgl) ~= 16
  error('gbcFMC on a single precision map: expected 16 grains, got %d', ...
    length(grainsSgl));
end

%% removeQuadruplePoints: a low angle threshold must not be overridden
%
% regression test for a bug in the private mergeQuadrupleGrains helper: it
% used a hardcoded 5 degree threshold to decide whether to merge grains
% split by a quadruple point, instead of the actual grain boundary
% criterion used for reconstruction - silently re-merging grains that a
% lower angle threshold had correctly kept separate.

qpThr = 2*degree;
ebsdQP1 = buildQuadPointGrid(cs, 3, [orientation.id(cs), ...
  orientation.byAxisAngle(xvector,3*degree,cs), ...
  orientation.byAxisAngle(yvector,3*degree,cs), ...
  orientation.byAxisAngle(zvector,3*degree,cs)]);

gPlain = calcGrains(ebsdQP1,'threshold',qpThr);
gQP    = calcGrains(ebsdQP1,'threshold',qpThr,'removeQuadruplePoints');

if length(gPlain) ~= 4 || length(gQP) ~= 4
  error(['calcGrains with removeQuadruplePoints merged grains that a ' ...
    'lower angle threshold should have kept separate ' ...
    '(expected 4 and 4 grains, got %d and %d)'], length(gPlain), length(gQP));
end

%% removeQuadruplePoints: grainId must stay the right length after a merge
%
% regression test for a second bug in mergeQuadrupleGrains: it used to
% rebuild the per-pixel grainId via find(I_DG.'), which drops all-zero
% rows (pixels not assigned to any single grain) and produces a grainId
% vector shorter than length(ebsd). The fix rebuilds grainId via the same
% matrix product used for the initial computation, which preserves the
% row count unconditionally. Orientations are chosen so the two grains
% meeting only diagonally at the quadruple point (blocks 1 and 4) are
% within qpThr of each other while the other two blocks are not, so
% removeQuadruplePoints actually triggers a merge (unlike the case above).

ebsdQP2 = buildQuadPointGrid(cs, 3, [orientation.id(cs), ...
  orientation.byAxisAngle(xvector,90*degree,cs), ...
  orientation.byAxisAngle(yvector,90*degree,cs), ...
  orientation.byAxisAngle(zvector,1*degree,cs)]);

gPlain2 = calcGrains(ebsdQP2,'threshold',qpThr);
[gQP2,ebsdQP2] = calcGrains(ebsdQP2,'threshold',qpThr,'removeQuadruplePoints');

if length(gPlain2) ~= 4 || length(gQP2) ~= 3
  error(['removeQuadruplePoints did not merge the diagonally-adjacent low ' ...
    'angle pair as expected (expected 4 and 3 grains, got %d and %d)'], ...
    length(gPlain2), length(gQP2));
end

if numel(ebsdQP2.grainId) ~= numel(ebsdQP2)
  error('ebsdQP2.grainId has %d entries, expected %d to match ebsd', ...
    numel(ebsdQP2.grainId), numel(ebsdQP2));
end

%% minPixel: a diagonal-only neighbour must not save an undersized grain
%
% regression test for #2513. The minPixel filter is a two pass scheme:
% minPixelMask sizes the grains once, marks the undersized ones notIndexed,
% and calcGrains then decomposes again. That sizing pass used the cheaper
% Delaunay-adjacency-only Voronoi build unconditionally, whose adjacency is
% a superset of the true Voronoi face adjacency wherever an interior vertex
% is exactly cocircular - which on a SQUARE lattice is every single one, so
% the whole map got sized 8-connected while the final segmentation is
% 4-connected. A pixel joined to a same-orientation grain only diagonally
% was therefore sized as part of it and survived a cull it should not have.
% Not a rare degeneracy: it left 393 of 3115 grains below minPixel on
% martensite and 655 of 3803 on emsland. A triangular (hex) lattice has no
% cocircular degeneracy, so the fast path is exact there and is kept.
%
% Both maps below are fully indexed, one stray pixel apart, so a survivor
% shows up directly as an indexed grain smaller than minPixel.

o2 = orientation.byAxisAngle(zvector,30*degree,cs);

% square: 2x2 block of o2, plus ONE stray o2 pixel touching that block only
% diagonally. In the final 4-connected segmentation the stray is its own
% grain of one pixel, so minPixel = 2 must remove it.
nMP = 8;
rotMPsq = rotation.id(nMP,nMP);
rotMPsq(1:2,1:2) = o2;
rotMPsq(3,3)     = o2;
ebsdMPsq = EBSDsquare([],rotMPsq,2*ones(nMP,nMP),[0 1],{'notIndexed',cs},'dxy',[1 1]);

checkMinPixel(calcGrains(ebsdMPsq,'threshold',thr,'minPixel',2), 2, 2, ...
  'square, stray pixel diagonal to a same-orientation block');

% hex: same shape of test on the grid that keeps the fast path, so an
% inverted gate or a broken hex path fails here rather than silently.
ebsdMPhex = buildHexBlockGrid(cs, nMP, 1, orientation.id(cs));
cMP = vector3d(mean(ebsdMPhex.pos.x(:)), mean(ebsdMPhex.pos.y(:)), 0);
[~,iMP] = min(norm(ebsdMPhex.pos(:) - cMP));   % innermost pixel, 6 neighbours
ebsdMPhex.rotations(iMP) = o2;

checkMinPixel(calcGrains(ebsdMPhex,'threshold',thr,'minPixel',2), 2, 1, ...
  'hex, single stray pixel');

disp('calcGrains cases: all checks passed');

end

% ===========================================================================
function ebsd = buildSquareBlockGrid(cs, blk, nb, oris)
% nb x nb grid of blk x blk pixel blocks on a square lattice, one
% orientation per block, with a few notIndexed holes and a cropped corner
% to also exercise the exterior dummy ring / map edge

n = nb*blk;
blockId = kron(reshape(1:nb^2,nb,nb),ones(blk));

rot = rotation.id(n,n);
for k = 1:nb^2
  rot(blockId==k) = oris(k);
end

phaseId = ones(n,n) + 1; % phase 2 = indexed, phase 1 = notIndexed
phaseId(8,8)   = 1;
phaseId(15,20) = 1;
phaseId(22,10) = 1;
phaseId(1:3,1:3) = 1; % crop a corner -> exercises the map edge / dummy ring

ebsd = EBSDsquare([],rot,phaseId,[0 1],{'notIndexed',cs},'dxy',[1 1]);

end

% ===========================================================================
function ebsd = buildHexBlockGrid(cs, blk, nb, oris)
% nb x nb grid of blk x blk pixel blocks on a hexagonal (triangular
% lattice) grid, one orientation per block; built from an unstructured
% point set and gridify-ed, since calcUnitCell auto-detects the hex unit
% cell from the point spacing (see EBSD/gridify)

n = nb*blk;
[c,r] = meshgrid(0:n-1,0:n-1);
x = c + mod(r,2)*0.5;
y = r*sqrt(3)/2;

blockId = kron(reshape(1:nb^2,nb,nb),ones(blk));

rot = rotation.id(n,n);
for k = 1:nb^2
  rot(blockId==k) = oris(k);
end

pos = vector3d(x(:),y(:),zeros(numel(x),1));
ebsd = EBSD(pos, rot(:), ones(numel(x),1), {cs}, struct());
ebsd = ebsd.gridify;

end

% ===========================================================================
function checkMinPixel(grains, minPixel, nExpected, label)
% no indexed grain may be left below minPixel, and the map must end up with
% the expected number of indexed grains (a cull that removed too much would
% otherwise pass the size assertion trivially)

g = grains(grains.isIndexed);

tooSmall = g.numPixel < minPixel;
if any(tooSmall)
  error(['minPixel (%s): %d indexed grain(s) below minPixel = %d survived ' ...
    'the cull, of sizes %s'], label, nnz(tooSmall), minPixel, ...
    mat2str(sort(g.numPixel(tooSmall)).'));
end

if length(g) ~= nExpected
  error('minPixel (%s): expected %d indexed grains, got %d', ...
    label, nExpected, length(g));
end

end

% ===========================================================================
function ebsd = buildQuadPointGrid(cs, blk, oris)
% 2x2 grid of blk x blk pixel blocks meeting at one quadruple point in the
% center

n = 2*blk;
blockId = kron([1 2; 3 4], ones(blk));

rot = rotation.id(n,n);
for k = 1:4
  rot(blockId==k) = oris(k);
end

ebsd = EBSDsquare([],rot,ones(size(rot)),1,{cs},'dxy',[1 1]);

end

% ===========================================================================
function checkTransformCommutation(ebsd, grains0, thr, label)
% trapezoidal stage-drift-like distortion, as in check_gridDistortionBenchmark.
% 0.02 is already a realistic-to-severe stage drift (2% x-scaling at the
% outermost rows); it clearly separates a correct local-deformation
% reconstruction (relErr ~ 1e-3) from a naively rigid one (relErr ~ 1e-2,
% an order of magnitude worse) without running into the unrelated
% topology effects (grains merging/splitting differently) that dominate
% at more extreme distortion levels.

x = ebsd.pos.x(:); xCenter = (min(x)+max(x))/2;
y = ebsd.pos.y(:); yCenter = (min(y)+max(y))/2; yHalf = (max(y)-min(y))/2;
trapFrac = 0.02;
distort = @(pos) vector3d( ...
  xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
  pos.y, pos.z);

ebsdT    = transform(ebsd, distort);
grainsT  = calcGrains(ebsdT,'threshold',thr);
grains0T = transform(grains0, distort);

compareCommutation(grainsT, grains0T, thr, label, 5e-3);

end

% ===========================================================================
function checkTransformCommutation2(ebsd, grains0, thr, label, varargin)
% same as checkTransformCommutation, but forwards extra calcGrains flags
% (e.g. 'delaunay') to both the reconstruction call and, implicitly via
% grains0, whatever flags were used to build grains0

x = ebsd.pos.x(:); xCenter = (min(x)+max(x))/2;
y = ebsd.pos.y(:); yCenter = (min(y)+max(y))/2; yHalf = (max(y)-min(y))/2;
trapFrac = 0.02;
distort = @(pos) vector3d( ...
  xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
  pos.y, pos.z);

ebsdT    = transform(ebsd, distort);
grainsT  = calcGrains(ebsdT,'threshold',thr,varargin{:});
grains0T = transform(grains0, distort);

compareCommutation(grainsT, grains0T, thr, label, 5e-3);

end

% ===========================================================================
function checkRotateCommutation(ebsd, grains0, thr, label)
% rigid rotation about the map center - unlike checkTransformCommutation,
% this leaves grain shapes/areas exactly invariant (up to rounding), but
% exercises a non-axis-aligned grid, stressing the same lattice-index
% recovery as check_gridDistortionBenchmark from a different angle

x = ebsd.pos.x(:); xCenter = (min(x)+max(x))/2;
y = ebsd.pos.y(:); yCenter = (min(y)+max(y))/2;
center = [xCenter yCenter];
ang = 27*degree;

ebsdR    = rotate(ebsd, ang, 'center', center);
grainsR  = calcGrains(ebsdR,'threshold',thr);
grains0R = rotate(grains0, ang, 'center', center);

compareCommutation(grainsR, grains0R, thr, label, 1e-3);

end

% ===========================================================================
function compareCommutation(grainsA, grainsB, thr, label, tol) %#ok<INUSD>

if length(grainsA) ~= length(grainsB)
  error(['calcGrains (%s) does not agree with transforming/rotating the ' ...
    'grains from the untransformed map: expected %d grains, got %d ' ...
    '(spurious/missing grains near holes or the map edge)'], ...
    label, length(grainsB), length(grainsA));
end

areaA = sort(area(grainsA));
areaB = sort(area(grainsB));
relErr = max(abs(areaA - areaB) ./ areaB);

if relErr > tol
  error(['calcGrains (%s) disagrees with transforming/rotating the grains ' ...
    'from the untransformed map beyond tolerance: max relative area error ' ...
    '%.4f (expected < %.4f)'], label, relErr, tol);
end

end
