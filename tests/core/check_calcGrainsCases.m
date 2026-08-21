function check_calcGrainsCases
% fast correctness suite for EBSD.calcGrains, covering grid type x
% transform combinations plus the removeQuadruplePoints option, on small
% synthetic maps throughout - with one deliberate exception, the stranded
% pixel case of #2574, which needs a real notIndexed topology and uses
% mtexdata('small').
%
% Takes about 4 s. The header used to claim "well under a second"; measured,
% it was already ~3.7 s before the #2574 case was added, which contributes
% 0.17 s of that.
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
% cells2posId placed a cell without measurement rigidly, so calcGrains did not commute with transform

ebsdSq = buildSquareBlockGrid(cs, 6, 4, ...
  orientation.byAxisAngle(zvector,(1:16)*7*degree,cs));
grains0Sq = calcGrains(ebsdSq,'threshold',thr);

if length(grains0Sq) ~= 16
  error('square grid: expected 16 grains, got %d', length(grains0Sq));
end

checkTransformCommutation(ebsdSq, grains0Sq, thr, 'square, transformed');
checkRotateCommutation(ebsdSq, grains0Sq, thr, 'square, rotated');

%% hex grid: plain reconstruction + transform/rotate commutation
% the same commutation checks on a hexagonal grid

ebsdHex = buildHexBlockGrid(cs, 5, 4, ...
  orientation.byAxisAngle(zvector,(1:16)*7*degree,cs));
grains0Hex = calcGrains(ebsdHex,'threshold',thr);

if length(grains0Hex) ~= 16
  error('hex grid: expected 16 grains, got %d', length(grains0Hex));
end

checkTransformCommutation(ebsdHex, grains0Hex, thr, 'hex, transformed');
checkRotateCommutation(ebsdHex, grains0Hex, thr, 'hex, rotated');

%% 'delaunay' flag: true alpha-complex backend (spatialDecompositionAlpha)
% a regular grid is cocircular everywhere, which is what the alpha complex has to handle

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
% single precision propagated into the edge weights, and sparse rejects them

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
% mergeQuadrupleGrains merged with a hardcoded 5 degree threshold, not the criterion

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
% mergeQuadrupleGrains rebuilt grainId with find, which drops the unassigned pixels

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

%% removeQuadruplePoints: two quadruple points sharing an edge
% #2590: two neighbouring quadruple points share an edge, and the repeated row kept only the last write

csQP3 = crystalSymmetry('m-3m','mineral','test');
[xQP,yQP] = meshgrid(0:3,0:3);
keepQP = logical([1 1 1 1; 0 1 1 1; 1 1 1 0; 0 1 1 1]);
oriQP3 = orientation.byEuler((1:16).'*11*degree,0,0,csQP3);

ebsdQP3 = gridify(EBSD(vector3d(xQP(keepQP),yQP(keepQP),0), oriQP3(keepQP), ...
  ones(nnz(keepQP),1), {csQP3}, struct()));

gQP3 = calcGrains(ebsdQP3,'threshold',qpThr,'removeQuadruplePoints');

if length(gQP3) ~= nnz(keepQP)
  error(['expected one grain per pixel on the quadruple point map, got %d ' ...
    'for %d pixels - the fixture no longer exercises the case'], ...
    length(gQP3), nnz(keepQP));
end

checkClosedBoundary(gQP3,'removeQuadruplePoints on adjacent quadruple points');

%% minPixel: a diagonal-only neighbour must not save an undersized grain
% #2513: the sizing pass was 8-connected on a square lattice, the segmentation 4-connected

o2 = orientation.byAxisAngle(zvector,30*degree,cs);

% square: a 2x2 block of o2 plus one stray pixel touching it only diagonally
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

% #2574: culling elsewhere moves the closing raster and strands a pixel across a gap
checkMinPixel(calcGrains(mtexdata('small','silent'),'minPixel',3), 3, 24, ...
  'stranded pixel, mtexdata small');

%% every grain polygon must be a closed ring enclosing a positive area
% a negative area means the ring was traced inside out, i.e. the boundary graph did not close

csRing = crystalSymmetry('432','mineral','test');
rng(3);
ebsdRing = EBSDsquare([],rotation.rand(30,30),2*ones(30,30),[0 1], ...
  {'notIndexed',csRing},'dxy',[0.3 0.3]);

for optRing = {{}, {'removeQuadruplePoints'}}

  what = 'calcGrains';
  if ~isempty(optRing{1}), what = 'calcGrains + removeQuadruplePoints'; end

  gRing = calcGrains(ebsdRing,'threshold',thr,optRing{1}{:});

  if length(gRing) < 100
    error('%s: expected a densely fragmented map, got %d grains - the test is not exercising quadruple points', ...
      what, length(gRing));
  end

  nNeg = nnz(gRing.area < 0);
  if nNeg > 0
    error(['%s: %d of %d grain polygons enclose a negative area, i.e. the ' ...
      'ring is traced inside out (smallest %.6f)'], ...
      what, nNeg, length(gRing), min(gRing.area));
  end

  % and the rings have to be closed
  notClosed = find(cellfun(@(p) p(1) ~= p(end), gRing.poly));
  if ~isempty(notClosed)
    error('%s: %d grain polygons are not closed rings (first is grain %d)', ...
      what, numel(notClosed), notClosed(1));
  end

  % the statement above is weaker than it reads - see checkClosedBoundary
  checkClosedBoundary(gRing,what);

end

%% removeQuadruplePoints must not depend on the order of the measurements
% the pairing at a quadruple point was taken from an angular sort sitting on atan2's branch cut

% a 4 x 4 block layout, so that many quadruple points have a pair within the threshold
oq = [orientation.id(cs), ...
      orientation.byAxisAngle(xvector,90*degree,cs), ...
      orientation.byAxisAngle(yvector,90*degree,cs), ...
      orientation.byAxisAngle(zvector,1*degree,cs)];
[rr,cc] = ndgrid(1:4,1:4);
qpIdx = 1 + (mod(rr,2)==0) + 2*(mod(cc,2)==0);   % o1 and o4 sit diagonally

ebsdQPord = buildSquareBlockGrid(cs, 6, 4, oq(qpIdx(:)), [0.3 0.3]);

qpIn = EBSD(ebsdQPord('indexed'));
rng(42);
qpShuf = qpIn(randperm(length(qpIn)));

gQPa = calcGrains(qpIn,  'threshold',thr,'removeQuadruplePoints');
gQPb = calcGrains(qpShuf,'threshold',thr,'removeQuadruplePoints');

% the test is vacuous unless the option actually does something here
gQPplain = calcGrains(qpIn,'threshold',thr);
if length(gQPa) == length(gQPplain)
  error(['removeQuadruplePoints changed nothing on this map (%d grains ' ...
    'either way), so the order invariance below is not being tested'], ...
    length(gQPa));
end

if length(gQPa) ~= length(gQPb)
  error(['removeQuadruplePoints depends on the order of the measurements: ' ...
    '%d grains as built, %d after shuffling the same pixels'], ...
    length(gQPa), length(gQPb));
end

% and the boundary itself, not just how many grains came out
La = sort(gQPa.boundary.segLength);
Lb = sort(gQPb.boundary.segLength);
if numel(La) ~= numel(Lb) || norm(La(:)-Lb(:),inf) > 1e-9*max(1,max(La))
  error(['removeQuadruplePoints gave a different boundary after shuffling ' ...
    'the measurements (%d segments vs %d)'], numel(La), numel(Lb));
end

%% gridify padding must segment exactly like notIndexed pixels
% a pad cell has phaseId NaN, which compares false against every phase and scored a boundary

ebsdPadBase = buildSquareBlockGrid(cs, 6, 4, ...
  orientation.byAxisAngle(zvector,(1:16)*7*degree,cs));

hole = false(size(ebsdPadBase));
hole(10:16,6:14) = true;             % spans four orientation blocks

% (A) the hole as missing measurements: drop those rows, then let gridify
%     pad the lattice sites back in with phaseId = NaN
ebsdPadA = gridify(ebsdPadBase(~hole));

% (B) the same cells, present but marked notIndexed
ebsdPadB = ebsdPadBase;
ebsdPadB.phaseId(hole) = 1;

% without real padding this test asserts nothing
nPad = nnz(isnan(ebsdPadA.phaseId));
if nPad ~= nnz(hole)
  error(['gridify padding test is vacuous: %d cells carry a NaN phaseId, ' ...
    'expected the %d cells of the hole'], nPad, nnz(hole));
end

gPadA = calcGrains(ebsdPadA,'threshold',thr);
gPadB = calcGrains(ebsdPadB,'threshold',thr);

niA = sort(gPadA(~gPadA.isIndexed).numPixel);
niB = sort(gPadB(~gPadB.isIndexed).numPixel);

if numel(niA) ~= numel(niB) || ~isequal(niA(:),niB(:))
  error(['a hole made of gridify padding segmented into %d notIndexed ' ...
    'grains, the same hole marked notIndexed into %d - the padding is ' ...
    'not being treated as notIndexed (largest %d vs %d pixels)'], ...
    numel(niA), numel(niB), max([niA(:);0]), max([niB(:);0]));
end

if nnz(gPadA.isIndexed) ~= nnz(gPadB.isIndexed)
  error('the two hole representations gave %d and %d indexed grains', ...
    nnz(gPadA.isIndexed), nnz(gPadB.isIndexed));
end

% the symptom was one grain per pad cell, so pin that the padding merged
if numel(niA) >= nPad
  error(['the %d pad cells produced %d notIndexed grains - contiguous ' ...
    'padding is being split into single-pixel grains'], nPad, numel(niA));
end

checkInsideEmptyQuery(cs, thr);

disp('calcGrains cases: all checks passed');

end

% ===========================================================================
function checkInsideEmptyQuery(cs, thr)
% grain2d/checkInside must accept an empty set of query points
%
% It built its query as vector3d.byXYZ([xy zeros(size(xy,1),1)]), i.e. it
% appended a zero column - to an n x 3 in the EBSD branch, which took byXYZ
% into its non-three-column path and dropped z, and which for an EMPTY query
% threw "Coordinates have different size" because the scalar z there could
% not be repmat-ed to a 0 x 1. EBSD/fill hits this by an entirely ordinary
% route: it collects the pixels it could interpolate, and hands checkInside
% whatever that is - including nothing, on a map with nothing to fill.
%
% Built here as a gapless map, unlike the shared fixture: calcGrains absorbs
% isolated notIndexed pixels and leaves them indexed with a NaN orientation,
% i.e. as something fill does have work to do on.

n = 12;
blockId = kron(reshape(1:4,2,2),ones(n/2));
rot = rotation.id(n,n);
oris = orientation.byAxisAngle(zvector,(1:4)*20*degree,cs);
for k = 1:4, rot(blockId==k) = oris(k); end

ebsd = EBSDsquare([],rot,2*ones(n,n),[0 1],{'notIndexed',cs},'dxy',[1 1]);

% fill needs the grainId, hence the two output reconstruction
[grains, ebsd] = calcGrains(ebsd,'threshold',thr);

isInside = checkInside(grains, zeros(0,2));
if ~isequal(size(isInside),[0 length(grains)])
  error('checkInside of an empty query gave %s, expected [0 %d]', ...
    mat2str(size(isInside)), length(grains));
end

isInside = checkInside(grains, ebsd.subSet([]));
if ~isequal(size(isInside),[0 length(grains)])
  error('checkInside of an empty EBSD gave %s, expected [0 %d]', ...
    mat2str(size(isInside)), length(grains));
end

% the reachable symptom: nothing left to fill
nNaN = nnz(isnan(ebsd.rotations));
if nNaN > 0
  error('fill test is vacuous: the map already has %d pixels to fill', nNaN);
end
filled = fill(ebsd, grains);
if length(filled) ~= length(ebsd)
  error('fill of a complete map changed its length from %d to %d', ...
    length(ebsd), length(filled));
end

end

% ===========================================================================
function ebsd = buildSquareBlockGrid(cs, blk, nb, oris, dxy)
% nb x nb grid of blk x blk pixel blocks on a square lattice, one
% orientation per block, with a few notIndexed holes and a cropped corner
% to also exercise the exterior dummy ring / map edge
%
% dxy defaults to [1 1]. A step that is not a round binary fraction - 0.3,
% say - makes the pixel and vertex coordinates inexact, which is what the
% quadruple point order invariance case needs: the branch cut it used to
% trip over is only reachable when the coordinates carry rounding.

if nargin < 5, dxy = [1 1]; end

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

ebsd = EBSDsquare([],rot,phaseId,[0 1],{'notIndexed',cs},'dxy',dxy);

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
function checkClosedBoundary(grains, label)
% every grain's boundary has to be a disjoint union of closed rings, i.e.
% every vertex it uses is met by an even number of the grain's own segments
%
% This is the sharp form of "the polygon closed". Testing grains.poly for
% p(1) == p(end) is not: EulerCycles closes every walk it returns by
% repeating the first vertex, so an open path is reported as a closed ring
% with one made-up segment in it. The degree statement cannot be faked that
% way, and it is what the tracers actually require of their input.

gB = grains.boundary;

% (grain, vertex) incidences of every boundary segment, both sides, both ends
gId = [gB.grainId(:,1);gB.grainId(:,1);gB.grainId(:,2);gB.grainId(:,2)];
vId = [gB.F(:,1);gB.F(:,2);gB.F(:,1);gB.F(:,2)];
keep = gId > 0;

deg = sparse(gId(keep),vId(keep),1);
odd = mod(deg,2) ~= 0 & deg ~= 0;

if any(odd(:))
  [gInd,vInd] = find(odd);
  error(['%s: %d grain(s) have a boundary that does not close - grain %d ' ...
    'meets vertex %d with an odd number of segments'], ...
    label, numel(unique(gInd)), grains.id(gInd(1)), vInd(1));
end

nNeg = nnz(grains.area < 0);
if nNeg > 0
  error('%s: %d of %d grain polygons enclose a negative area', ...
    label, nNeg, length(grains));
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
