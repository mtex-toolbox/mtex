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

%% completeBoundaries: close a one-edge bridge between two grains
%
% The two halves differ by 10 degrees, except for one neighboring pair at
% the interface with orientations 4 and 6 degrees. With a 5 degree
% threshold this single pair connects both halves under the standard
% connected-component definition. Boundary completion must cut the bridge
% and turn the otherwise inner boundary into an external grain boundary.

n = 10;
mid = n/2;
bridgeRow = n/2;
oriLeft = orientation.id(cs);
oriRight = orientation.byAxisAngle(zvector,10*degree,cs);

rot = rotation.id(n,n);
rot(:,1:mid) = oriLeft;
rot(:,mid+1:end) = oriRight;
rot(bridgeRow,mid) = orientation.byAxisAngle(zvector,4*degree,cs);
rot(bridgeRow,mid+1) = orientation.byAxisAngle(zvector,6*degree,cs);

ebsdBridge = EBSDsquare([],rot,ones(size(rot)),1,{cs},'dxy',[1 1]);
gConnected = calcGrains(ebsdBridge,'threshold',thr);
gCompleted = calcGrains(ebsdBridge,'threshold',thr,'completeBoundaries');

if length(gConnected) ~= 1
  error('bridge case: standard reconstruction should return one grain, got %d', ...
    length(gConnected));
end

if length(gConnected.innerBoundary) == 0
  error('bridge case: standard reconstruction did not expose the inner boundary');
end

if length(gCompleted) ~= 2
  error('bridge case: boundary completion should return two grains, got %d', ...
    length(gCompleted));
end

if length(gCompleted.innerBoundary) ~= 0
  error('bridge case: completed reconstruction still contains inner boundaries');
end

if any(sort(gCompleted.numPixel) ~= [50;50])
  error('bridge case: expected two grains with 50 pixels each');
end

%% completeBoundaries: ignore enclosed one- and two-segment fragments
%
% A 3 degree background, one 0 degree centre pixel and selected 6 degree
% neighbours produce isolated >5 degree faces while every alternative
% connection stays below the threshold. Enclosed components with one or two
% segments are treated as pixel noise. Three segments are retained and must
% be completed.

nNoise = 7;
c = (nNoise+1)/2;
neighbours = [c,c+1; c-1,c; c,c-1];
oriMid = orientation.byAxisAngle(zvector,3*degree,cs);
oriHigh = orientation.byAxisAngle(zvector,6*degree,cs);

for numSegments = 1:2
  rotNoise = rotation.id(nNoise,nNoise);
  rotNoise(:) = oriMid;
  rotNoise(c,c) = orientation.id(cs);
  for k = 1:numSegments
    rotNoise(neighbours(k,1),neighbours(k,2)) = oriHigh;
  end

  ebsdNoise = EBSDsquare([],rotNoise,ones(size(rotNoise)),1,{cs},'dxy',[1 1]);
  gNoiseRaw = calcGrains(ebsdNoise,'threshold',thr);
  gNoise = calcGrains(ebsdNoise,'threshold',thr,'completeBoundaries');

  if length(gNoiseRaw.innerBoundary) ~= numSegments
    error('noise case: expected %d inner segments, got %d', ...
      numSegments,length(gNoiseRaw.innerBoundary));
  end
  if length(gNoise) ~= 1 || length(gNoise.innerBoundary) ~= 0
    error(['noise case: an enclosed %d-segment boundary fragment should ' ...
      'be ignored without splitting the grain'],numSegments);
  end
end

gNoiseMinPixel = calcGrains(ebsdNoise,'threshold',thr,'minPixel',2, ...
  'completeBoundaries');
if length(gNoiseMinPixel) ~= 1 || length(gNoiseMinPixel.innerBoundary) ~= 0
  error(['noise case: the conservative minPixel sizing pass must preserve ' ...
    'the ignored short boundary fragment']);
end

rotNoise = rotation.id(nNoise,nNoise);
rotNoise(:) = oriMid;
rotNoise(c,c) = orientation.id(cs);
for k = 1:3
  rotNoise(neighbours(k,1),neighbours(k,2)) = oriHigh;
end

ebsdNoise = EBSDsquare([],rotNoise,ones(size(rotNoise)),1,{cs},'dxy',[1 1]);
gNoise = calcGrains(ebsdNoise,'threshold',thr,'completeBoundaries');
if length(gNoise) ~= 2 || length(gNoise.innerBoundary) ~= 0
  error(['noise case: an enclosed three-segment boundary must be retained ' ...
    'and completed']);
end

%% completeBoundaries: retain a short fragment that reaches the map boundary

rotEdge = rotation.id(nNoise,nNoise);
rotEdge(:) = oriMid;
rotEdge(1,c) = orientation.id(cs);
rotEdge(1,c+1) = oriHigh;

ebsdEdge = EBSDsquare([],rotEdge,ones(size(rotEdge)),1,{cs},'dxy',[1 1]);
gEdgeRaw = calcGrains(ebsdEdge,'threshold',thr);
gEdge = calcGrains(ebsdEdge,'threshold',thr,'completeBoundaries');

if length(gEdgeRaw.innerBoundary) ~= 1
  error('edge case: expected one inner boundary segment');
end
if length(gEdge) ~= 2 || length(gEdge.innerBoundary) ~= 0
  error(['edge case: a short inner boundary connected to the map boundary ' ...
    'must be retained and completed']);
end

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
