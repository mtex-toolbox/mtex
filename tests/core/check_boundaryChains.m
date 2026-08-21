function check_boundaryChains
% verify that grain boundary segments are stored in walk order
%
% Segments of a @grainBoundary are stored so that consecutive segments of
% the same chain share a vertex, each chain runs between junctions, and each
% chain is oriented with grainId(:,1) on its left. This checks all of that,
% plus that the invariant survives every operation that touches F.

%% the reference map

ebsd = mtexdata('small','silent');
[grains,ebsd] = calcGrains(ebsd('indexed'));
gB = grains.boundary;

%% 1. the invariant itself

assertOrdered(gB,'grains.boundary');
assertOrdered(grains.innerBoundary,'grains.innerBoundary');

%% 2. chains break at junctions and nowhere else

deg = accumarray(gB.F(:),1,[size(gB.allV,1) 1]);
if ~isequal(gB.junctionId,find(deg ~= 2 & deg > 0))
  error('junctionId is not the set of vertices of degree ~= 2');
end

% every chain start that is not the very first segment follows a junction,
% or a break in the row order
iStart = find(gB.isChainStart);
iStart(1) = [];
if ~all(deg(gB.F(iStart-1,2)) ~= 2 | gB.F(iStart,1) ~= gB.F(iStart-1,2))
  error('a chain starts at a vertex where exactly two segments meet');
end

% and no chain runs through a junction
iInner = find(~gB.isChainEnd);
if any(deg(gB.F(iInner,2)) ~= 2)
  error('a chain runs through a junction');
end

% junctions are a strict superset of the triple points
if ~all(ismember(gB.triplePoints.id,gB.junctionId))
  error('a triple point is not a junction');
end
if numel(gB.junctionId) <= length(gB.triplePoints)
  error('expected strictly more junctions than triple points on this map');
end

%% 3. chain census

expect(size(gB.F,1),976,'number of segments');
expect(max(gB.chainId),172,'number of chains');
expect(max(gB.chainSize),62,'longest chain');
expect(nnz(gB.chainSize == 1),41,'singleton chains');
expect(numel(gB.junctionId),101,'junctions');
expect(length(gB.triplePoints),65,'triple points');
expect(nnz(gB.isClosed & gB.isChainStart),22,'closed chains');
expect(numel(gB.chainV),size(gB.F,1) + 2*max(gB.chainId),'chainV length');

%% 4. the two grains are the same along a whole chain

gp = sort(gB.grainId,2);
notFirst = find(~gB.isChainStart);
if ~isequal(gp(notFirst,:),gp(notFirst-1,:))
  error('the grain pair changes within a chain');
end

%% 5. grainId(:,1) lies to the left of the walk direction

id2ind = zeros(max(ebsd.id),1);
id2ind(ebsd.id) = 1:length(ebsd);
pos = ebsd.pos;

mid = gB.midPoint;
dir = gB.allV(gB.F(:,2)) - gB.allV(gB.F(:,1));

isInner = gB.ebsdId(:,1) > 0;
w = dir;
w(isInner) = pos(id2ind(gB.ebsdId(isInner,1))) - mid(isInner);
if any(dot(cross(dir(isInner),w(isInner)),gB.N) <= 0)
  error('grainId(:,1) is not on the left for every inner segment');
end

% along the outer border grainId(:,1) is 0, so the real grain is on the right
isOuter = ~isInner & gB.ebsdId(:,2) > 0;
w = dir;
w(isOuter) = pos(id2ind(gB.ebsdId(isOuter,2))) - mid(isOuter);
if any(dot(cross(dir(isOuter),w(isOuter)),gB.N) >= 0)
  error('the outer border does not have its grain on the right');
end

%% 6. closed chains close, and enclose a real area

isClosedChain = gB.isClosed & gB.isChainStart;
if ~any(isClosedChain), error('expected closed chains on this map'); end

cId = gB.chainId;
kap = curvature(gB,0);
sl = gB.segLength;

for k = reshape(find(isClosedChain),1,[])

  s = find(cId == cId(k));
  if gB.F(s(end),2) ~= gB.F(s(1),1)
    error('a chain flagged closed does not close');
  end

  % polySgnArea does not wrap, so the first vertex has to be repeated
  xy = gB.allV(gB.F([s; s(1)],1)).xyz;
  area = polySgnArea(xy(:,1),xy(:,2));
  if area == 0
    error('a closed chain encloses no area');
  end

  % the curvature sign has to follow the walk direction, so the total
  % turning around a closed chain has the sign of its signed area
  if sign(sum(kap(s).*sl(s))) ~= sign(area)
    error('the curvature sign does not follow the walk direction');
  end

end

%% 7. arc length runs from zero to the chain length

al = gB.arcLength;
if any(al <= 0), error('arc length is not positive'); end
if max(abs(al(gB.isChainStart) - gB.segLength(gB.isChainStart))) > 1e-9
  error('arc length does not restart at each chain');
end
if max(abs(al(gB.isChainEnd) - gB.chainLength(gB.isChainEnd))) > 1e-9
  error('chainLength does not match the arc length at the chain end');
end
if abs(sum(gB.segLength) - sum(al(gB.isChainEnd))) > 1e-6
  error('the chain lengths do not add up to the total boundary length');
end

%% 8. order is idempotent, and subsets stay ordered

if ~isequal(gB.order.F,gB.F)
  error('order is not idempotent');
end

assertOrdered(gB(gB.isIndexed),'gB(isIndexed)');
assertOrdered(gB('Forsterite','Enstatite'),'phase pair subset');
assertOrdered(gB(gB.segLength > median(gB.segLength)),'scattered subset');
assertOrdered(grains(5).boundary,'single grain boundary');
assertOrdered([grains.boundary; grains.innerBoundary],'cat');

%% 9. every producer and mutator leaves the invariant intact

% meanOrientation is single phase only, so rebuild from the stored rotations
g2 = grain2d(grains.allV,grains.poly,grains.prop.meanRotation,...
  grains.CSList,grains.phaseId,grains.phaseMap);
assertOrdered(g2.boundary,'grain2d(V,poly,...)');

% misorientation angles are single phase only
gBfo = grains.boundary('Forsterite','Forsterite');
gm = merge(grains,gBfo(angle(gBfo.misorientation) < 15*degree));
assertOrdered(gm.boundary,'merge');

assertOrdered(smoothBoundary(grains,3).boundary,'smoothBoundary');
assertOrdered(smoothBoundary(grains,3,'noSimplify','noRefine').boundary,...
  'smoothBoundary(noSimplify,noRefine)');

% every backend has to leave the boundary walkable, and none of them may move
% a junction or change the segment list - they only move vertices
for F = {laplaceFilter(3),taubinFilter(3),curvatureFilter,huberFilter}

  name = class(F{1});
  gS = smoothBoundary(grains,F{1});

  assertOrdered(gS.boundary,name);

  if ~isequal(gS.boundary.F,smoothBoundary(grains,0).boundary.F)
    error('%s changed the segment list, it should only move vertices',name);
  end

  isJunction = full(diag(gS.boundary.I_VF*gS.boundary.I_VF.')) > 2;
  moved = norm(gS.allV - smoothBoundary(grains,0).allV) > 1e-10;
  if any(moved & isJunction)
    error('%s moved a junction',name);
  end

end
assertOrdered(refineBoundary(grains).boundary,'refineBoundary');
assertOrdered(hull(grains).boundary,'hull');
assertOrdered(flip(gB),'flip');

%% 10. a boundary saved before walk order existed is ordered on load

fName = [tempname '.mat'];
cleanup = onCleanup(@() delete(fName)); %#ok<NASGU>

scrambled = gB.subSet(randperm(length(gB))); %#ok<NASGU>
save(fName,'scrambled');
loaded = load(fName);
assertOrdered(loaded.scrambled,'loadobj of an unordered boundary');

% an older file also has an arbitrary column order in F, which only grain2d can repair
assertLeftGrain(grains,'the reference map');

stale = grains;
gBstale = gB;
gBstale.F = fliplr(gBstale.F);
stale.boundary = gBstale;

save(fName,'stale');
repaired = load(fName);

assertOrdered(repaired.stale.boundary,'loadobj of a reversed boundary');
assertLeftGrain(repaired.stale,'loadobj of a reversed boundary');

% reversing every segment and turning it back has to land on the boundary we
% started from, not merely on a consistent one
if ~isequal(repaired.stale.boundary.F,gB.F)
  error('loadobj did not restore the original segment directions');
end

% and a boundary that was already right is left alone
wellFormed = grains;
save(fName,'wellFormed');
untouched = load(fName);
if ~isequal(untouched.wellFormed.boundary.F,gB.F)
  error('loadobj changed a boundary that already satisfied the convention');
end

%% 11. a second, independent map

ebsd = mtexdata('twins','silent');
[grains2,ebsd] = calcGrains(ebsd('indexed'),'angle',5*degree);
assertOrdered(grains2.boundary,'twins');
gp2 = sort(grains2.boundary.grainId,2);
nf = find(~grains2.boundary.isChainStart);
if ~isequal(gp2(nf,:),gp2(nf-1,:))
  error('the grain pair changes within a chain on twins');
end

%% 12. the consumers built on the chain structure

% curvature is undefined exactly at the ends of open chains
kap = curvature(gB);
undefined = (gB.isChainStart | gB.isChainEnd) & ~gB.isClosed;
if ~isequal(isnan(kap),undefined)
  error('curvature is not NaN exactly at the ends of the open chains');
end
if ~(any(kap > 0) && any(kap < 0))
  error('curvature is not signed');
end

% the mean direction window must never degenerate, whatever its size
for n = [1 2 3 5 10 50]
  md = calcMeanDirection(gB,n);
  if any(isnan(md.x))
    error('calcMeanDirection produced a zero length direction for n = %d',n);
  end
end

% reducing keeps the topology of the network intact
for f = [2 3 4]
  red = reduce(gB,f);
  assertOrdered(red,sprintf('reduce(gB,%d)',f));
  if ~isequal(red.junctionId,gB.junctionId)
    error('reduce(gB,%d) changed the junctions',f);
  end
  if max(red.chainId) ~= max(gB.chainId)
    error('reduce(gB,%d) changed the number of chains',f);
  end
  if length(red) >= length(gB)
    error('reduce(gB,%d) did not remove any segment',f);
  end
end

% both plotting paths still run
fig = figure('visible','off');
cleanupFig = onCleanup(@() close(fig)); %#ok<NASGU>
plot(gB,'linewidth',5,'parent',gca);
gBfo2 = gB('Forsterite','Forsterite');
plot(gBfo2,angle(gBfo2.misorientation)./degree,'linewidth',5);
plot(gB);

%% 13. simplify and refine

sl = median(gB.segLength);

prevCount = length(gB);
for eps = [sl/4 sl/2 sl 2*sl]

  sim = simplify(gB,eps);
  assertOrdered(sim,sprintf('simplify(gB,%g)',eps));

  if ~isequal(sim.junctionId,gB.junctionId)
    error('simplify moved or dropped a junction');
  end
  if max(sim.chainId) ~= max(gB.chainId)
    error('simplify changed the number of chains');
  end
  if length(sim) >= prevCount
    error('simplify did not get coarser as the tolerance grew');
  end
  prevCount = length(sim);

  % every dropped vertex has to have been within eps of the kept line, so
  % the boundary can only get shorter, and not by much
  if sum(sim.segLength) > sum(gB.segLength) + 1e-9
    error('simplify made the boundary longer');
  end

end

% simplify beats reduce: fewer segments for more retained length
red = reduce(gB,2);
sim = simplify(gB,sl);
if length(sim) >= length(red) || ...
    sum(sim.segLength)/sum(gB.segLength) < sum(red.segLength)/sum(gB.segLength) - 0.05
  error('simplify is not a better coarsening than reduce');
end

% refine resamples onto the same curve, so it keeps the shape
ref = refine(gB,sl/2);
assertOrdered(ref,'refine');
if ~isequal(ref.junctionId,gB.junctionId)
  error('refine moved or dropped a junction');
end
if max(ref.chainId) ~= max(gB.chainId)
  error('refine changed the number of chains');
end
if length(ref) <= length(gB)
  error('refine did not add any segment');
end

% equal spacing is the whole point - away from the chains that are shorter
% than delta, the segments have to come out at the target length
if abs(median(ref.segLength) - sl/2) > 0.05*sl
  error('refine did not resample at the requested spacing');
end

% cutting corners between samples can only shorten the boundary, slightly
lenRatio = sum(ref.segLength)/sum(gB.segLength);
if lenRatio > 1 + 1e-9 || lenRatio < 0.95
  error('refine changed the boundary length by %.2f%%',100*(lenRatio-1));
end

% and the grain shapes survive the round trip through grain2d
gRef = refineBoundary(grains);
assertConsistent(gRef,grains,'refineBoundary');
assertNotHanging(gRef,grains,'refineBoundary');
if max(abs(gRef.area - grains.area)) > 1e-3*max(abs(grains.area))
  error('refineBoundary changed the grain areas');
end
if length(gRef.triplePoints) ~= length(grains.triplePoints)
  error('refineBoundary changed the triple points');
end

%% 14. the grain2d wrappers keep the grains in sync with their boundary

% coarsening the boundary moves the polygons too, so poly and inclusionId are retraced

gSim = simplifyBoundary(grains,sl);
assertConsistent(gSim,grains,'simplifyBoundary');
assertNotHanging(gSim,grains,'simplifyBoundary');

% Douglas-Peucker keeps every dropped vertex within sl of the chord that
% replaces it, so the area swept per grain is at most about sl*perimeter
dA = abs(gSim.area - grains.area);
if any(dA > 1.01*sl*grains.perimeter)
  error('simplifyBoundary moved a grain area by more than eps*perimeter');
end

% the boundary really did get coarser, and the grains followed
if length(gSim.boundary) >= length(grains.boundary)
  error('simplifyBoundary did not coarsen the boundary');
end
if sum(cellfun(@numel,gSim.poly)) >= sum(cellfun(@numel,grains.poly))
  error('simplifyBoundary coarsened the boundary but not the polygons');
end

% junctions are untouched, so the triple points are the same ones - and their
% boundaryId has to point into the renumbered segment list
if length(gSim.triplePoints) ~= length(grains.triplePoints)
  error('simplifyBoundary changed the triple points');
end
if ~isequal(sort(gSim.triplePoints.id),sort(grains.triplePoints.id))
  error('simplifyBoundary moved a triple point');
end
bId = gSim.triplePoints.boundaryId;
if any(bId(:) < 0) || any(bId(:) > length(gSim.boundary))
  error('simplifyBoundary left triplePoints.boundaryId pointing past the segment list');
end

% a tolerance beyond the size of the smallest grains must not flatten one onto a line
for eps = [2*sl 5*sl 20*sl]
  gBig = simplifyBoundary(grains,eps);
  assertConsistent(gBig,grains,sprintf('simplifyBoundary(grains,%g*sl)',eps/sl));
  if length(gBig) ~= length(grains)
    error('simplifyBoundary changed the number of grains');
  end
end

% reduceBoundary is the same contract, just a blunter rule
gRed = reduceBoundary(grains,2);
assertConsistent(gRed,grains,'reduceBoundary');
assertNotHanging(gRed,grains,'reduceBoundary');
if length(gRed.boundary) >= length(grains.boundary)
  error('reduceBoundary did not coarsen the boundary');
end

% all three have to be correct on a subset, where grains.id is not 1:N and
% boundary.I_FG therefore has columns that do not line up with poly
iSub = 5:min(10,length(grains));
gSub = grains(iSub);
for f = {@(g) simplifyBoundary(g,sl), @(g) reduceBoundary(g,2), @refineBoundary}

  gOut = f{1}(gSub);
  name = func2str(f{1});

  if numel(gOut.poly) ~= numel(iSub)
    error('%s on a subset returned %d polygons for %d grains',...
      name,numel(gOut.poly),numel(iSub));
  end
  assertConsistent(gOut,gSub,name);

  % misaligned polygons show up as areas belonging to the wrong grains
  if any(abs(gOut.area - gSub.area) > 1.01*sl*gSub.perimeter + 1e-9)
    error('%s on a subset assigned the polygons to the wrong grains',name);
  end

end

disp('check_boundaryChains passed');

end

% -------------------------------------------------------------------------
function assertConsistent(grains,grains0,name)
% everything a grain2d has to satisfy after its boundary was rewritten

assertOrdered(grains.boundary,[name ' boundary']);
assertOrdered(grains.innerBoundary,[name ' innerBoundary']);

poly = grains.poly;

if ~all(cellfun(@(p) p(1) == p(end),poly))
  error('%s left an unclosed poly loop',name);
end

% three distinct vertices plus the repeated first one, fewer encloses no area
if any(cellfun(@numel,poly) < 4)
  error('%s collapsed a poly loop to fewer than three vertices',name);
end

if ~all(grains.area > 0)
  error('%s left %d grains with a non-positive area',name,nnz(grains.area<=0));
end

if any(cellfun(@(p) any(p < 1 | p > size(grains.allV,1)),poly))
  error('%s left a poly index outside allV',name);
end

% every poly vertex has to be one the boundary still walks through
onBnd = false(size(grains.allV,1),1);
onBnd(grains.boundary.F(:)) = true;
if ~all(cellfun(@(p) all(onBnd(p)),poly))
  error('%s left poly walking through a vertex the boundary dropped',name);
end

% inclusionId counts the trailing entries of poly that belong to hole loops -
% the constructor derives it this way, see grain2d/grain2d.m
inclusionId = cellfun(@(p) numel(p) - find(p(2:end)==p(1),1),poly) - 1;
if ~isequal(reshape(inclusionId,[],1),reshape(grains.inclusionId,[],1))
  error('%s left inclusionId out of sync with poly',name);
end

end

% -------------------------------------------------------------------------
function assertNotHanging(grains,grains0,name)
% a vertex shared by the two boundaries has to stay on both of them, or one is
% left hanging off a vertex the other no longer visits. All three wrappers pass
% those vertices down as 'protect' - refine has to cut its chains there, since
% it otherwise keeps only the two junctions of a chain and mints fresh ids for
% everything between them.

shared0 = intersect(grains0.boundary.F(:),grains0.innerBoundary.F(:));
if isempty(shared0), return; end

nV = size(grains.allV,1);

onBnd = false(nV,1);
onBnd(grains.boundary.F(:)) = true;
if ~all(onBnd(shared0))
  error('%s dropped a vertex the inner boundary still ends on',name);
end

onInner = false(nV,1);
onInner(grains.innerBoundary.F(:)) = true;
if ~all(onInner(shared0))
  error('%s dropped an inner vertex the outer boundary still ends on',name);
end

end

% -------------------------------------------------------------------------
function assertLeftGrain(grains,name)
% walked with the grain on its left, a grain boundary runs counterclockwise
% around it, so it encloses exactly +area. This says the same as the pixel
% based check in section 5, but from the geometry alone - which is what makes
% it applicable to a stored grain2d that carries no ebsd

gB = grains.boundary;
V1 = gB.allV(gB.F(:,1));
V2 = gB.allV(gB.F(:,2));
c = 0.5*dot(cross(V1,V2),normalize(gB.N));

area = grains.area;
for k = 1:length(grains)
  A = sum(c(gB.grainId(:,1) == grains.id(k))) - sum(c(gB.grainId(:,2) == grains.id(k)));
  if abs(A - area(k)) > 1e-6*area(k)
    error('%s: grain %d encloses %g instead of its area %g - its boundary is walked the wrong way round',...
      name,grains.id(k),A,area(k));
  end
end

end

% -------------------------------------------------------------------------
function assertOrdered(gB,name)

if length(gB) < 2, return; end

F = gB.F;
isStart = gB.isChainStart;
bad = nnz(~isStart(2:end) & F(2:end,1) ~= F(1:end-1,2));
if bad > 0
  error('%s: %d segments do not continue the previous one',name,bad);
end

% chains have to be contiguous, i.e. each chain id appears in one block
if ~issorted(gB.chainId)
  error('%s: chains are not stored in contiguous blocks',name);
end

end

% -------------------------------------------------------------------------
function expect(actual,wanted,name)

if actual ~= wanted
  error('%s: expected %d, got %d',name,wanted,actual);
end

end
