function check_spatialShift
% checks that shifting a spatial object by plus/minus really translates it
%
% grainBoundary and triplePointList shifted their vertices through
% [v.x,v.y] + repmat(...), written when allV / V were an n × 2 double. They
% are a vector3d now, and against a vector3d that route adds an n × 2 matrix
% to each n × 1 coordinate array, so implicit expansion turns them into
% n × 2. The result is a silently nonsensical object - no error anywhere, and
% the damage only surfaces much later.
%
% The obsolete numeric form, obj + [100,0], expands in exactly the same way
% (a 1 × 2 row against the coordinate arrays) and is now rejected outright
% rather than accepted and misread; it is what made issue #1722 look like a
% calcUnitCell bug, since gridify of such an object tries to build a lattice
% spanning the fake coordinate range and runs the machine out of memory.
%
% Assertions are on the positions themselves, not just on the point count: a
% shift is exactly a translation, so every coordinate moves by the same
% amount and neither the object's size nor the shape of its coordinate
% arrays changes.
%
% See also
% EBSD/plus grain2d/plus grainBoundary/plus triplePointList/plus

[ebsd,grains] = fixture;

checkTranslation(ebsd,'EBSD');
checkTranslation(grains,'grain2d');
checkTranslation(grains.boundary,'grainBoundary');
checkTranslation(grains.triplePoints,'triplePointList');

checkFarShiftStaysGriddable(ebsd);

checkNumericRejected(ebsd,'EBSD');
checkNumericRejected(grains,'grain2d');
checkNumericRejected(grains.boundary,'grainBoundary');
checkNumericRejected(grains.triplePoints,'triplePointList');

disp('check_spatialShift: passed');

end

% =========================================================================
function checkTranslation(obj,cls)
% obj + v moves every point by v, and by nothing else

v = vector3d(12.5,-7.25,0);
shifted = obj + v;

assert(isequal(size(shifted),size(obj)), ...
  '%s + vector3d changed the size from %s to %s', ...
  cls, mat2str(size(obj)), mat2str(size(shifted)));

% the expansion happens inside the coordinate arrays, which size(obj) does not see
pos = positions(obj); posShifted = positions(shifted);
assert(isequal(size(posShifted.x),size(pos.x)), ...
  '%s + vector3d expanded the coordinate arrays from %s to %s', ...
  cls, mat2str(size(pos.x)), mat2str(size(posShifted.x)));

dev = max(norm(posShifted - (pos + v)));
assert(isempty(dev) || dev < 1e-12, ...
  '%s + vector3d is not a rigid translation, off by %g', cls, dev);

% and minus is the inverse of plus
dev = max(norm(positions(shifted - v) - pos));
assert(isempty(dev) || dev < 1e-12, ...
  '%s: minus does not undo plus, off by %g', cls, dev);

end

% =========================================================================
function checkFarShiftStaysGriddable(ebsd)
% the lattice index is relative to the map, so it must not grow with the shift
%
% This is the assertion that would have caught #1722 where it actually
% happens. A map 10 units across on a 0.5 grid has ~20 cells per direction no
% matter where in the plane it sits; a shift that is not a translation drove
% this to the shift divided by the step size, and gridify then allocated that
% many nodes.

far = ebsd + vector3d(-3500,10,0);

assert(length(far) == length(ebsd), ...
  'shifting an EBSD map changed the number of measurements from %d to %d', ...
  length(ebsd), length(far));

expected = ebsd.extent + [-3500 -3500 10 10 0 0];
assert(max(abs(far.extent - expected)) < 1e-9, ...
  'the shifted extent is %s, expected %s', mat2str(far.extent,6), mat2str(expected,6));

ijHere = max(ebsd.lattice.ij);
ijFar = max(far.lattice.ij);
assert(isequal(ijHere,ijFar), ...
  ['moving the map far from the origin changed its lattice index range '...
  'from %s to %s'], mat2str(ijHere), mat2str(ijFar));

end

% =========================================================================
function checkNumericRejected(obj,cls)
% the obsolete obj + [x,y] form errors instead of expanding silently

for bad = {[100 0], [100 0 0], rand(5,2), 'x'}
  try
    obj + bad{1}; %#ok<VUNUS>
    error('check_spatialShift:noError', ...
      '%s: shifting by a %s %s was accepted', ...
      cls, mat2str(size(bad{1})), class(bad{1}));
  catch ME
    assert(strcmp(ME.identifier,'MTEX:shift:invalidShift'), ...
      '%s: shifting by a %s raised %s instead of MTEX:shift:invalidShift', ...
      cls, class(bad{1}), ME.identifier);
  end
end

end

% =========================================================================
function pos = positions(obj)

if isa(obj,'EBSD')
  pos = obj.pos(:);
elseif isa(obj,'triplePointList')
  pos = obj.V(:);
else % grain2d, grainBoundary
  pos = obj.allV(:);
end

end

% =========================================================================
function [ebsd,grains] = fixture
% a small synthetic map of three wedges, so the boundary graph has triple
% points as well as boundaries

n = 20; d = 0.5;
[Y,X] = ndgrid((0:n-1)*d,(0:n-1)*d);

angleAround = atan2(Y(:)-n*d/2, X(:)-n*d/2);
wedge = min(floor(mod(angleAround,2*pi) / (2*pi/3)) + 1, 3);
rot = rotation.byAxisAngle(vector3d.Z, (wedge-1)*20*degree);

ebsd = EBSD(vector3d(X(:),Y(:),zeros(n*n,1)), rot, ...
  ones(n*n,1), {crystalSymmetry('m-3m')}, struct('bc',rand(n*n,1)));

grains = calcGrains(ebsd,'threshold',5*degree);

assert(~isempty(grains.triplePoints), ...
  'check_spatialShift: the fixture produced no triple points');

end
