function check_ebsdTransform
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

disp('check_ebsdTransform: passed');

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
