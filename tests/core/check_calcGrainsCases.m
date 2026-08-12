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

%% removeQuadruplePoints: two quadruple points sharing an edge
%
% regression test for #2590. Splitting a quadruple point detaches two of its
% four edges and rewrites their shared vertex to a duplicate at the same
% coordinates. That rewrite was done row wise, Fext(rows,:) = ..., over all
% quadruple points at once - and two quadruple points that are neighbours
% share the edge between them, so that edge is in the relocation list of
% both. A repeated row in a MATLAB assignment silently keeps only the last
% write, so one of the two rewrites was lost: the edge kept the original
% vertex where it should have taken the duplicate. The quadruple point then
% carries three of its four edges instead of two, the duplicate carries one,
% and the boundary of the grain whose corner was cut there is an open path
% rather than a closed ring - which no tracer can turn into a polygon.
%
% On an ideal square grid the two never collide: the edge shared by two
% horizontally adjacent quadruple points points +x at one and -x at the
% other, and the angular sort puts those in different relocation slots. It
% takes an irregular neighbourhood - a hole, a map border - for the sort to
% land both in the same slot, which is why this needs a map with missing
% pixels and why real maps show it only a few times each (one collision on
% forsterite, martensite and epidote, three on mylonite, two negative area
% grains on the 2.5M pixel steel map of the benchmark).
%
% Every pixel is its own grain here, so every interior grid corner is a
% quadruple point. The hole pattern is the smallest one found that makes the
% collision fire.

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

%% every grain polygon must be a closed ring enclosing a positive area
%
% The cheapest statement of "the reconstruction is topologically sound", and
% the one the suite was missing. A grain's polygon is a ring traced so that
% the interior lies to one side; if it comes out with NEGATIVE area the ring
% was traced inside out, which means the boundary graph did not close and
% everything downstream - area, equivalent radius, smoothBoundary, plotting -
% is reading a polygon that is not the grain.
%
% It is not hypothetical. Making the pairing at a quadruple point
% deterministic (b2ca13189, 14463616f) produced up to 117 such grains on
% alphaBetaTitanium, and none of the tests here noticed: they assert grain
% COUNTS, and a broken ring does not change the count. It surfaced only when
% a grain was plotted by hand. Those 117 were in fact #2590 - the pairing
% change merely moved the shared edge of two neighbouring quadruple points
% into the relocation slot where the lost write bit - and the pairing work is
% back in the tree with the fix under it, so what this case now guards is
% that the two stay compatible.
%
% The regime that exposes it is a dense one - many small grains, so quadruple
% points everywhere - not the block maps above, which have too few. Per pixel
% random orientations on a 30 x 30 grid give ~900 grains and reproduce it in
% under a second. The step is 0.3 rather than 1 for the same reason as the
% gridify padding case below: with integer coordinates atan2 lands exactly on
% its branch cut every time and the ambiguity never arises.

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
%
% Reconstruction is a function of the measurements, not of the sequence they
% were written down in - shuffling the input has to give the same grains.
% Plain calcGrains always did; removeQuadruplePoints did not.
%
% At a quadruple point the four incident boundary edges are paired, and the
% two possible pairings pick out the two DIAGONALS of the four pixels
% meeting there. The pairing was taken from the position of the edges in
% the angular sort, and on a square grid the edges leave the vertex along
% +-x and +-y - so one of them sits exactly on atan2's branch cut at +-pi.
% 1e-14 of noise in the Voronoi vertex, which is all a different
% measurement order produces, flipped that edge between +pi and -pi,
% rotated the sorted order by one and swapped the pairing. On twins that
% was 110 grains against 108, and it is also what made a gridified map
% disagree with the same map as a list (gridify reorders - see
% EBSD/gridify).
%
% The tie cannot be broken geometrically: all four angular gaps are exactly
% pi/2. It is broken by the criterion, and where that is indifferent by the
% pixel positions - both properties of the data, neither of the order.

% a 4 x 4 block layout tiling the same four orientations the merge test
% above uses, so that every interior quadruple point has one diagonal pair
% within the threshold and there are many of them to disagree about
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
%
% The two ways of saying "nothing was measured here" have to give the same
% grains. A scan whose file simply omits those positions gets them back
% from gridify as lattice sites with phaseId = NaN; a scan that records
% them as unindexed has them present with phaseId = 1. spatialDecomposition
% Grid's help states the two are treated identically - they were not.
%
% Every grain boundary criterion selects its pixels with a test of the form
% phaseId(i) == p, and NaN compares false against every phase, so the pad
% cells matched no phase, scored 0 (= high angle boundary) against each of
% their neighbours, and each came out as its own single-pixel grain. On
% forsterite with a solid 5841 cell hole that was 5842 notIndexed grains
% instead of 6. Only the notIndexed count moved - the indexed grains were
% identical either way - which is why it stayed invisible for so long, and
% why this asserts on the notIndexed grains specifically.
%
% Fixed in grainBoundaryCriterion/eval, which normalises NaN to phase 1 for
% every criterion and every caller at once.

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

disp('calcGrains cases: all checks passed');

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
