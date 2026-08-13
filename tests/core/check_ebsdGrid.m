function check_ebsdGrid
% checks on EBSD grid geometry and on multi channel properties
%
% Owns three things that all live on the grid: that unitCell stays consistent
% with pos under a transformation, so lattice.ij keeps indexing the right
% pixel, that the unitCell property itself accepts what calcUnitCell hands
% back, and that an N x k property survives indexing and assignment.
%
% Merged from check_ebsdTransform and check_dynProp, two of the files that
% one bug-fixing session in August 2026 produced one-per-bug. Both cases are
% kept verbatim below with their own explanation of the regression they pin.
% check_dynProp's fixture was called makeMap, which collided with the one in
% check_ebsdTransform, so it is makeMultiPropMap here.
%
% See also
% EBSD/transform EBSD/lattice dynProp

checkTransform;
checkUnitCellProperty;
checkGridShapes;
checkMultiColumnProps;
checkLatticeBasisCanonical;
checkLatticeIndexOrderInvariance;

disp('check_ebsdGrid: passed');

end

% =========================================================================
function checkUnitCellProperty
% calcUnitCell's output has to be usable as ebsd.unitCell, and has to be
% finite even for a degenerate map
%
% Two regressions, both silent. calcUnitCell returns an n x 2 list of
% coordinates while the property is a vector3d, so the documented recompute
% ebsd.unitCell = calcUnitCell(xy) stored a raw double (#2531) that every
% later reader of the property - plot, lattice, calcGrains - then tripped
% over, far from the assignment. And on a single scan line the coordinate
% that does not vary leaves uniquetol a single value, so mean(diff(.)) is
% NaN and the cell came out with a NaN side, which then propagates into
% anything derived from it.

d = 0.3; ebsd = makeMap(12,d);

% the double form is accepted and converted
uC = calcUnitCell(ebsd.pos.xyz);
assert(isnumeric(uC),'check_ebsdGrid: calcUnitCell no longer returns a double');

ebsd.unitCell = uC;
assert(isa(ebsd.unitCell,'vector3d'), ...
  'check_ebsdGrid: assigning calcUnitCell''s output left unitCell a %s', ...
  class(ebsd.unitCell));
assert(max(abs([ebsd.unitCell.x - uC(:,1), ebsd.unitCell.y - uC(:,2)]),[],'all') == 0 ...
  && all(ebsd.unitCell.z == 0), ...
  'check_ebsdGrid: the converted unit cell does not hold calcUnitCell''s coordinates');

% and the object stays usable, i.e. the lattice can still be derived
assert(isequal(size(ebsd.lattice.ij),[length(ebsd) 2]), ...
  'check_ebsdGrid: lattice fails on a unit cell assigned as a double');

% a single scan line - the y coordinate never varies
n = 24;
line = EBSD(vector3d((0:n-1).'*d,zeros(n,1),zeros(n,1)), rotation.rand(n,1), ...
  ones(n,1), {crystalSymmetry('m-3m')}, struct());

uCLine = calcUnitCell([line.pos.x(:), line.pos.y(:)]);
assert(all(isfinite(uCLine),'all'), ...
  'check_ebsdGrid: calcUnitCell on a single scan line returned %s', mat2str(uCLine,4));
assert(abs(range(uCLine(:,1)) - d) < 1e-12 && abs(range(uCLine(:,2)) - d) < 1e-12, ...
  'check_ebsdGrid: the single scan line cell is %g x %g, expected %g x %g', ...
  range(uCLine(:,1)),range(uCLine(:,2)),d,d);

assert(all(isfinite(line.unitCell.xyz),'all'), ...
  'check_ebsdGrid: the constructor stored a non finite unit cell for a single scan line');

end

% =========================================================================
function checkTransform
% check that EBSD/transform keeps the unit cell consistent with the positions
%
% Regression: transform applied fun to pos only and left ebsd.unitCell
% describing the pre-transformation pixel. That is not cosmetic - ebsd.lattice
% derives the lattice basis from the unit cell ALONE and then assigns every
% pixel its integer index against that basis, so a cell that disagrees with
% pos misindexes the map for calcGrains, gradient, smooth and fill.
%
% The fix pushes the cell through fun about the centre of the map, the same
% way rotate pushes it through the rotation.

checkTranslation;
checkScale;
checkShear;
checkRotationAgreesWithRotate;
checkGridInvariants;
checkTrapezoidalDrift;


end

% =========================================================================
function checkTranslation
% a pure translation moves no pixel relative to its neighbours

d = 0.3; ebsd = makeMap(12,d);
uC0 = ebsd.unitCell;

ebsdT = transform(ebsd, @(pos) pos + vector3d(3,-2,0));

dev = cellDeviation(ebsdT.unitCell,uC0);
assert(dev < 1e-12*d, ...
  'check_ebsdTransform: a pure translation changed the unit cell by %g (step %g)',dev,d);

end

% =========================================================================
function checkScale
% a uniform scale scales the cell by the same factor

d = 0.3; s = 2.5; ebsd = makeMap(12,d);
uC0 = ebsd.unitCell;

ebsdT = transform(ebsd, @(pos) s * pos);

dev = cellDeviation(ebsdT.unitCell,s*uC0);
assert(dev < 1e-12*d, ...
  'check_ebsdTransform: scaling by %g is off by %g in the unit cell',s,dev);

assert(abs(mean(norm(ebsdT.unitCell))/mean(norm(uC0)) - s) < 1e-12, ...
  'check_ebsdTransform: scaling by %g scaled the cell size by %g',...
  s,mean(norm(ebsdT.unitCell))/mean(norm(uC0)));

end

% =========================================================================
function checkShear
% a shear is the case the old code got wrong: pos becomes a parallelogram
% lattice while the cell stays the original square

d = 0.3; g = 0.3; ebsd = makeMap(12,d);
uC0 = ebsd.unitCell;

ebsdT = transform(ebsd, @(pos) shear(pos,g));

% the cell is a linear image of the old one, exactly
dev = cellDeviation(ebsdT.unitCell,shear(uC0,g));
assert(dev < 1e-12*d, ...
  'check_ebsdTransform: shearing by %g is off by %g in the unit cell',g,dev);

% and so the lattice basis derived from it is the sheared old basis. Note
% g = 0.3 keeps latticeBasis picking the same pair of translations for
% a1/a2 - it takes the two that are closest to orthogonal, and a shear
% tilts them by asin(g/sqrt(1+g^2)), so beyond g = 0.577 the pair would be
% permuted and this direct comparison would need the permutation too
S = [1 g; 0 1];
dA = norm(latticeBasis(ebsdT.unitCell) - S*latticeBasis(uC0),'fro');
assert(dA < 1e-12*d, ...
  'check_ebsdTransform: the sheared lattice basis is off by %g',dA);

% the per pixel lattice index is what everything downstream consumes, and
% a smooth transformation must leave it alone
assert(isequal(ebsdT.lattice.ij, ebsd.lattice.ij), ...
  'check_ebsdTransform: shearing by %g changed the lattice index of %d pixels',...
  g,nnz(any(ebsdT.lattice.ij ~= ebsd.lattice.ij,2)));

end

% =========================================================================
function checkRotationAgreesWithRotate
% a rotation expressed as a fun must give what rotate gives - rotate is the
% pre-existing rigid case implementation and already pushes the cell through

d = 0.3; ang = 27*degree; ebsd = makeMap(12,d);
rot = rotation.byAxisAngle(zvector,ang);

ebsdR = rotate(ebsd,ang);
ebsdT = transform(ebsd, @(pos) rot .* pos);

% 1e-10 rather than 1e-12: rotate additionally runs round2zero
dev = cellDeviation(ebsdT.unitCell,ebsdR.unitCell);
assert(dev < 1e-10*d, ...
  'check_ebsdTransform: transform and rotate disagree by %g on the unit cell',dev);

devPos = max(norm(ebsdT.pos - ebsdR.pos));
assert(devPos < 1e-10*d, ...
  'check_ebsdTransform: transform and rotate disagree by %g on the positions',devPos);

end

% =========================================================================
function checkGridInvariants
% on a grid class the cell has a second consumer: it must keep describing
% the step between adjacent matrix entries, which d1/d2 read off pos

d = 0.3; g = 0.3; ebsdG = gridify(makeMap(12,d));

assert(isa(ebsdG,'EBSDsquare'), ...
  'check_ebsdTransform: the synthetic map gridified to %s',class(ebsdG));

checkCellMatchesSteps(ebsdG,'before the transformation');

ebsdT = transform(ebsdG, @(pos) shear(pos,g));

assert(isa(ebsdT,'EBSDsquare'), ...
  'check_ebsdTransform: transform downgraded an EBSDsquare to %s',class(ebsdT));

checkCellMatchesSteps(ebsdT,'after a shear');

assert(isequal(ebsdT.lattice.ij, ebsdG.lattice.ij), ...
  'check_ebsdTransform: shearing a grid changed the lattice index of %d pixels',...
  nnz(any(ebsdT.lattice.ij ~= ebsdG.lattice.ij,2)));

end

% =========================================================================
function checkTrapezoidalDrift
% the realistic case - a smooth but non-affine stage drift, as used by
% check_calcGrainsCases and check_gridDistortionBenchmark

d = 0.3; trapFrac = 0.02; ebsd = makeMap(20,d);
uC0 = ebsd.unitCell;

x = ebsd.pos.x(:); xCenter = (min(x)+max(x))/2;
y = ebsd.pos.y(:); yCenter = (min(y)+max(y))/2; yHalf = (max(y)-min(y))/2;
distort = @(pos) vector3d( ...
  xCenter + (pos.x-xCenter) .* (1 + trapFrac*(pos.y-yCenter)/yHalf), ...
  pos.y, pos.z);

ebsdT = transform(ebsd,distort);

% a 2% drift must leave a square cell square - in particular it must not
% come back as a hexagon, which is what recomputing it via calcUnitCell
% would risk
assert(length(ebsdT.unitCell) == 4, ...
  'check_ebsdTransform: a %g%% drift turned the 4 corner cell into %d corners',...
  100*trapFrac,length(ebsdT.unitCell));

assert(all(isfinite(norm(ebsdT.unitCell))), ...
  'check_ebsdTransform: a %g%% drift produced a non finite unit cell',100*trapFrac);

% the drift is the identity at the centre of the map, so the cell taken
% there is the original one to within the drift magnitude
rel = abs(mean(norm(ebsdT.unitCell))/mean(norm(uC0)) - 1);
assert(rel < 2*trapFrac, ...
  'check_ebsdTransform: a %g%% drift changed the cell size by %g%%',...
  100*trapFrac,100*rel);

assert(isequal(ebsdT.lattice.ij, ebsd.lattice.ij), ...
  'check_ebsdTransform: a %g%% drift changed the lattice index of %d pixels',...
  100*trapFrac,nnz(any(ebsdT.lattice.ij ~= ebsd.lattice.ij,2)));

end

% =========================================================================
function checkCellMatchesSteps(ebsd,when)
% the two cell to cell translations of the unit cell are the two matrix
% steps d1/d2, up to sign and order

A = latticeBasis(ebsd.unitCell);
a = vector3d(A(1,:),A(2,:),[0 0]);
steps = [ebsd.d1, ebsd.d2];
tol = 1e-9 * mean(norm(steps));

for k = 1:2
  dev = min(min(norm(a(k) - steps)),min(norm(a(k) + steps)));
  assert(dev < tol, ...
    'check_ebsdTransform: %s the unit cell translation (%s) is %g away from d1 (%s) and d2 (%s)',...
    when,char(a(k)),dev,char(ebsd.d1),char(ebsd.d2));
end

end

% =========================================================================
function v = shear(pos,g)

v = vector3d(pos.x + g*pos.y, pos.y, pos.z);

end

% =========================================================================
function dev = cellDeviation(uC,uCRef)
% corner wise distance, after checking the corner counts agree

assert(length(uC) == length(uCRef), ...
  'check_ebsdTransform: the unit cell has %d corners, expected %d',...
  length(uC),length(uCRef));

dev = max(norm(uC(:) - uCRef(:)));

end

% =========================================================================
function ebsd = makeMap(sz,d)
% a plain square map as a flat list, built the way check_gridify does

[Y,X] = ndgrid((0:sz-1)*d,(0:sz-1)*d);

ebsd = EBSD(vector3d(X(:),Y(:),zeros(numel(X),1)), rotation.rand(numel(X),1), ...
  ones(numel(X),1), {crystalSymmetry('m-3m')}, struct('bc',rand(numel(X),1)));

end

% =========================================================================
function checkGridShapes
% every per pixel view of a gridded map is the (r x c) matrix of the map
%
% Regression (#2128): phase came back as an (r*c) x 1 list while id,
% rotations, pos, isIndexed and every prop were the matrix, so the one
% property a sliding window analysis indexes by (row,col) was the one that
% could not be. phaseId itself is the storage and stays a column - as it
% already did when isIndexed was given the same reshape - so the assertion
% is about what the user reads off the object, not about how it is held.

d = 0.3; sz = 12;
ebsd = makeMap(sz,d);
grid = ebsd.gridify;

assert(isequal(size(grid),[sz sz]), ...
  'check_ebsdGrid: the fixture did not gridify to %d x %d but to %s', ...
  sz,sz,mat2str(size(grid)));

for fn = {'id','phase','isIndexed','rotations','pos','bc'}
  v = grid.(char(fn));
  assert(isequal(size(v),size(grid)), ...
    'check_ebsdGrid: %s of a gridded map is %s, expected the map shape %s', ...
    char(fn), mat2str(size(v)), mat2str(size(grid)));
end

% an ungridded map is a flat list, and phase must not be reshaped there
assert(isequal(size(ebsd.phase),size(ebsd)), ...
  'check_ebsdGrid: phase of a plain list is %s, expected %s', ...
  mat2str(size(ebsd.phase)), mat2str(size(ebsd)));

% a grainBoundary carries a phase on each side - n x 2 against an n x 1
% object, so it is the one per entry view that must keep its columns
grains = calcGrains(ebsd,'threshold',5*degree);
gB = grains.boundary;
assert(isequal(size(gB.phase),size(gB.phaseId)) && size(gB.phase,2) == 2, ...
  'check_ebsdGrid: grainBoundary phase is %s, expected the n x 2 of phaseId %s', ...
  mat2str(size(gB.phase)), mat2str(size(gB.phaseId)));

end

% =========================================================================
function checkMultiColumnProps
% check that multi channel (N x k) properties survive indexing and assignment
%
% A property does not have to be one number per object - a forescatter image
% is 5 channels, so it is stored as one N x 5 property rather than 5 separate
% ones. dynProp/subSet has always known that, but its two siblings did not:
%
%  - subsasgn appended the ':' that keeps the columns to the SHARED subscript
%    inside the per property loop, so a second N x k property appended a
%    second ':', and it wrote s.subs instead of s(1).subs
%  - the delete branch of subsasgn had no N x k case at all, so ebsd(ind)=[]
%    hit A(ind)=[] on a matrix, which MATLAB rejects
%  - subsref's '()' branch had none either. That branch is currently dead -
%    every MTEX class strips '()' in its own subsref and routes it through
%    subSet - so this file cannot reach it, and it is fixed for consistency
%    only
%
% Note ebsd(ind) and subSet(ebsd,ind) agreeing is asserted below because it
% was reported as broken. It was not - both go through subSet - and it has
% to stay that way.

[ebsd,fs,im,bc] = makeMultiPropMap;

checkIndexing(ebsd,fs,im,bc);
checkAssignment(ebsd);
checkAssignmentNewField(ebsd);
checkDeletion(ebsd);
checkCat(ebsd);


end

% =========================================================================
function checkIndexing(ebsd,fs,im,bc)

n = length(ebsd);

for indCell = {[3 7 11 20], (1:n).' > n/2}

  ind = indCell{1};
  what = 'a linear index'; if islogical(ind), what = 'a logical mask'; end

  sub = ebsd(ind);

  assert(isequal(sub.fs,fs(ind,:)), ...
    'check_dynProp: %s gives an fs of %s, expected %s',...
    what,mat2str(size(sub.fs)),mat2str(size(fs(ind,:))));

  assert(isequal(sub.im,im(ind,:)), ...
    'check_dynProp: %s gives an im of %s, expected %s',...
    what,mat2str(size(sub.im)),mat2str(size(im(ind,:))));

  assert(isequal(sub.bc,bc(ind)), ...
    'check_dynProp: %s does not keep an ordinary property',what);

  % the two routes into a subset must not disagree
  sub2 = subSet(ebsd,ind);
  assert(isequal(sub2.fs,sub.fs) && isequal(sub2.im,sub.im) && ...
    isequal(sub2.bc,sub.bc), ...
    'check_dynProp: ebsd(ind) and subSet(ebsd,ind) disagree for %s',what);

end

end

% =========================================================================
function checkAssignment(ebsd)
% writing a subset back. With two N x k properties the old code appended a
% second ':' to the shared subscript while handling the second one

ind = [2 5 9 14];

b = ebsd(ind);
b.fs = -b.fs;
b.im = -b.im;
b.bc = -b.bc;

e = ebsd;
e(ind) = b;

assert(isequal(e.fs(ind,:),-ebsd.fs(ind,:)), ...
  'check_dynProp: assigning a subset did not write the first N x k property');

assert(isequal(e.im(ind,:),-ebsd.im(ind,:)), ...
  'check_dynProp: assigning a subset did not write the second N x k property');

assert(isequal(e.bc(ind),-ebsd.bc(ind)), ...
  'check_dynProp: assigning a subset did not write an ordinary property');

% and nothing outside ind moved
keep = true(length(ebsd),1); keep(ind) = false;
assert(isequal(e.fs(keep,:),ebsd.fs(keep,:)) && ...
  isequal(e.im(keep,:),ebsd.im(keep,:)) && ...
  isequal(e.bc(keep),ebsd.bc(keep)), ...
  'check_dynProp: assigning a subset changed rows outside the subset');

assert(isequal(size(e.fs),size(ebsd.fs)) && isequal(size(e.im),size(ebsd.im)), ...
  'check_dynProp: assigning a subset resized fs to %s and im to %s',...
  mat2str(size(e.fs)),mat2str(size(e.im)));

end

% =========================================================================
function checkAssignmentNewField(ebsd)
% the target does not carry the multi channel property yet, so a placeholder
% is created for it - it has to be N x k, not N x 1

ind = [4 8 12];

e = ebsd;
e.prop = rmfield(e.prop,'fs');

b = ebsd(ind);
e(ind) = b;

assert(isequal(size(e.fs),[length(ebsd) size(ebsd.fs,2)]), ...
  'check_dynProp: a newly created multi channel property has size %s, expected %s',...
  mat2str(size(e.fs)),mat2str([length(ebsd) size(ebsd.fs,2)]));

assert(isequal(e.fs(ind,:),ebsd.fs(ind,:)), ...
  'check_dynProp: a newly created multi channel property did not get the values');

end

% =========================================================================
function checkDeletion(ebsd)
% ebsd(ind) = [] used to hit A(ind) = [] on an N x k property

ind = [1 6 13];
keep = true(length(ebsd),1); keep(ind) = false;

e = ebsd;
e(ind) = [];

assert(length(e) == length(ebsd) - numel(ind), ...
  'check_dynProp: deleting %d of %d measurements left %d',...
  numel(ind),length(ebsd),length(e));

assert(isequal(size(e.fs),[length(e) size(ebsd.fs,2)]), ...
  'check_dynProp: after a deletion fs is %s, expected %s',...
  mat2str(size(e.fs)),mat2str([length(e) size(ebsd.fs,2)]));

assert(isequal(e.fs,ebsd.fs(keep,:)) && isequal(e.im,ebsd.im(keep,:)) && ...
  isequal(e.bc,ebsd.bc(keep)), ...
  'check_dynProp: a deletion kept the wrong rows');

end

% =========================================================================
function checkCat(ebsd)
% note this prints "Duplicated Ids detected" - concatenating a map with
% itself genuinely does that, and it is not what is under test here

e = [ebsd; ebsd];

assert(isequal(size(e.fs),[2*length(ebsd) size(ebsd.fs,2)]), ...
  'check_dynProp: concatenation gives an fs of %s, expected %s',...
  mat2str(size(e.fs)),mat2str([2*length(ebsd) size(ebsd.fs,2)]));

assert(isequal(e.fs,[ebsd.fs;ebsd.fs]) && isequal(e.im,[ebsd.im;ebsd.im]), ...
  'check_dynProp: concatenation does not stack the multi channel properties');

end

% =========================================================================
function checkLatticeBasisCanonical
% latticeBasis must read the lattice off the CELL, not off the order its
% corners happen to be listed in
%
% The corner order is not an invariant of a unit cell: the importers hand
% out one order and squarify sorts the corners by angle before gridding,
% which on a square cell also reverses the winding. latticeBasis used to
% take a1 = trans(1,:) and a2 = the first orthogonal entry, so the same
% 50 x 50 square gave A = [50 0; 0 50] one way and A = [-50 0; 0 50] the
% other - a MIRRORED, left handed (i,j) frame. That propagated through
% assignGridIndex into the spatial decomposition and changed the
% reconstruction from identical measurements: on forsterite 2931 grains and
% a total boundary length of 2109862.588230 against 2936 and 2109862.726874.
%
% So: every way of writing down the same cell must give one basis, and it
% must be right handed.

d = 50;
sq = vector3d([d d -d -d],[-d d d -d],0)/2;   % as the importers give it

variants = {'as given', sq};
variants(end+1,:) = {'reversed winding', sq(end:-1:1)};
for s = 1:3
  variants(end+1,:) = {sprintf('rotated start by %d',s), sq([1+s:4 1:s])}; %#ok<AGROW>
end
% the order squarify itself produces
omega = angle(sq,vector3d(-1,-1,0),zvector);
[~,a] = sort(omega);
variants(end+1,:) = {'squarify order', sq(a)};

[Aref,stRef,dRef] = latticeBasis(variants{1,2});

assert(det(Aref) > 0, ...
  'check_ebsdGrid: latticeBasis gave a left handed basis, det = %g', det(Aref))

for k = 1:size(variants,1)

  [A,st,dxy] = latticeBasis(variants{k,2});

  assert(isequal(size(A),[2 2]) && norm(A - Aref,'fro') < 1e-9*d, ...
    ['check_ebsdGrid: latticeBasis depends on the corner order - the same ' ...
    'square cell written "%s" gave A = %s, expected %s'], ...
    variants{k,1}, mat2str(A(:).',6), mat2str(Aref(:).',6))

  assert(det(A) > 0, ...
    'check_ebsdGrid: latticeBasis gave a left handed basis for "%s", det = %g', ...
    variants{k,1}, det(A))

  assert(isequal(st,stRef) && abs(dxy-dRef) < 1e-9*d, ...
    'check_ebsdGrid: latticeBasis stencil/spacing changed with the corner order for "%s"', ...
    variants{k,1})

end

% a rotated cell must be just as insensitive - the basis rotates with it,
% but not with how its corners are written down
rot = rotation.byAxisAngle(zvector,20*degree);
sqR = rot * sq;
Arot = latticeBasis(sqR);
assert(det(Arot) > 0, ...
  'check_ebsdGrid: latticeBasis gave a left handed basis on a rotated cell')
assert(norm(latticeBasis(sqR(end:-1:1)) - Arot,'fro') < 1e-9*d, ...
  'check_ebsdGrid: latticeBasis on a rotated cell depends on the winding')

% and the hexagonal branch, which picks its basis by angle already
hx = vector3d(cos((0:5)*60*degree),sin((0:5)*60*degree),0)*d;
Ahex = latticeBasis(hx);
assert(det(Ahex) > 0, ...
  'check_ebsdGrid: latticeBasis gave a left handed basis on a hex cell')
assert(norm(latticeBasis(hx(end:-1:1)) - Ahex,'fro') < 1e-9*d, ...
  'check_ebsdGrid: latticeBasis on a hex cell depends on the winding')

end

% =========================================================================
function [ebsd,fs,im,bc] = makeMultiPropMap
% a plain map carrying TWO multi channel properties next to an ordinary one -
% one alone does not expose the subscript that accumulates across the loop

n = 24; d = 0.3;

fs = reshape(1:5*n,n,5);          % readable values, so a flattened result
im = -reshape(1:3*n,n,3);         % is obvious from the numbers themselves
bc = (1:n).';

ebsd = EBSD(vector3d((0:n-1).'*d,zeros(n,1),zeros(n,1)), rotation.rand(n,1), ...
  ones(n,1), {crystalSymmetry('m-3m')}, struct('fs',fs,'im',im,'bc',bc));

assert(isequal(size(ebsd.fs),[n 5]) && isequal(size(ebsd.im),[n 3]), ...
  'check_dynProp: the constructor already flattened the multi channel properties');

end

% =========================================================================
function checkLatticeIndexOrderInvariance
% the same measurements in a different list order get the same lattice index
%
% assignGridIndex walks the list and rounds each step, which needs the list
% in raster order but must not care WHICH raster order. It did: the walk
% trusted the outer component of a step outright, and a line change undoes a
% whole line's worth of inner travel in one step, so any drift the outer
% coordinate picked up along that line came along with it. Reading the map
% down its columns makes the distorted direction the outer one and the jump
% back to the next column then rounded to anything but the +1 it is.
%
% Silent, and only on a distorted map: the indices collide, gridify writes
% the colliding measurements onto one cell with mesh(ind) = pos, so one of
% each pair is dropped and the survivor sits a full step away from where it
% was measured. Exposed by EBSD.load gridding on import, which is what put
% real maps into column major order for the first time.
%
% The map has to be wide enough for the drift over one line to exceed half a
% cell - trapFrac * (line length) here, i.e. about 2 cells at these numbers.
% A small toy grid stays correct at a distortion that already breaks this one.

n1 = 29; n2 = 41; d = 0.3; trapFrac = 0.05;

[Y,X] = ndgrid((0:n1-1)*d,(0:n2-1)*d);

% trapezoidal stage drift: scale x about the map centre by an amount growing
% linearly with y, i.e. the distortion runs along x
xCenter = (min(X(:))+max(X(:)))/2;
yCenter = (min(Y(:))+max(Y(:)))/2; yHalf = (max(Y(:))-min(Y(:)))/2;
X = xCenter + (X-xCenter) .* (1 + trapFrac*(Y-yCenter)/yHalf);

% the same points in the two raster orders: column major (y fastest, what
% gridify produces) and row major (x fastest, what a .ctf is written in)
posCol = [X(:) Y(:)];
perm = reshape(1:numel(X),n1,n2).';
posRow = posCol(perm(:),:);

ijCol = latticeIndexOf(posCol);
ijRow = latticeIndexOf(posRow);

for c = {ijCol,'column major'; ijRow,'row major'}.'
  ij = c{1}; label = c{2};
  assert(size(unique(ij,'rows'),1) == size(ij,1), ...
    ['check_ebsdGrid: %s order puts %d of %d measurements on a lattice cell '...
    'another one already holds'], label, ...
    size(ij,1) - size(unique(ij,'rows'),1), size(ij,1));
  assert(isequal(sort(max(ij,[],1)),sort([n1 n2]-1)), ...
    'check_ebsdGrid: %s order spans a %s lattice, expected %s', ...
    label, mat2str(max(ij,[],1)+1), mat2str(sort([n1 n2])));
end

% and the two agree measurement by measurement, up to which lattice
% direction ended up first
same = isequal(ijCol(perm(:),:),ijRow) || isequal(ijCol(perm(:),[2 1]),ijRow);
assert(same, ...
  'check_ebsdGrid: the two raster orders give different lattice indices');

end

% =========================================================================
function ij = latticeIndexOf(pos)
% lattice index of a plain list of xy coordinates

n = size(pos,1);
ebsd = EBSD(vector3d(pos(:,1),pos(:,2),zeros(n,1)), rotation.rand(n,1), ...
  ones(n,1), {crystalSymmetry('m-3m')}, struct());

ij = ebsd.lattice.ij;

end
