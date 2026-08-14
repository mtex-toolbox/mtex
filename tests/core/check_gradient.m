function check_gradient
% EBSD/gradient, gradientX/Y/Z - lattice native, so grid free
%
% The gradient used to exist only on @EBSDsquare / @EBSDhex, as a shift of
% the data matrix, and gradientX/Y/Z only worked when a grid direction was
% exactly along an axis - anything else hit error('Todo'). It is now
% computed on the virtual lattice (ebsd.lattice), so a plain list, a phase
% subset, a rotated grid and a sheared grid are all the same code path.
%
% Two things are checked:
%
%  * a synthetic field with a KNOWN constant gradient is recovered, on five
%    geometries. This is the test that could not be written before: three of
%    the five error out on the old code.
%  * on an axis aligned square map the new one sided gradient is BIT
%    identical to the old matrix based gradient1/gradient2, NaN placement
%    included, so no GND / WBV number moves.

checkLinearField;
checkBitIdenticalToSquare;
checkEdgeAndHoles;
checkLeastSquaresOnLinear;
checkStencilChoice;
checkOffPlaneMap;
checkShapeFollowsInput;

disp('gradient: all checks passed');

end

% =========================================================================
function checkLinearField
% o(x) = exp(skew(kappa*x)) has a constant, known specimen gradient

cs = crystalSymmetry('m-3m');
k1 = 0.002; k2 = 0.0035;          % 1/um, small enough to stay linear

geom = {'square axis aligned', 'square rotated 30', 'square rotated 45', ...
  'square sheared', 'hex'};

for c = 1:numel(geom)

  pos = makePositions(geom{c});

  % a linear rotation field: axis fixed, angle linear in x and y
  omega = k1*pos.x + k2*pos.y;
  ori = orientation.byAxisAngle(zvector,omega,cs);

  ebsd = EBSD(pos,ori,ones(length(pos),1),{cs},struct);
  ebsd.unitCell = unitCellOf(geom{c});

  gX = ebsd.gradientX;
  gY = ebsd.gradientY;

  % dO/dx is k1 about z, dO/dy is k2 about z - away from the border, where
  % the one sided difference reaches outside
  inner = interiorMask(ebsd);

  % cast to plain vector3d: an SO3TangentVector refuses arithmetic with a
  % non tangent vector, and here we only want to compare the components
  eX = max(norm(vector3d(gX(inner)) - k1*zvector));
  eY = max(norm(vector3d(gY(inner)) - k2*zvector));

  assert(eX < 1e-8 && eY < 1e-8, ...
    ['check_gradient: %s - gradient does not recover the known linear ' ...
    'field (max error %.3g in x, %.3g in y)'], geom{c}, eX, eY);

  % out of plane has no answer for a map in the xy plane
  assert(all(isnan(ebsd.gradientZ)), ...
    'check_gradient: %s - gradientZ should be NaN for a map in the xy plane', ...
    geom{c});

end

end

% =========================================================================
function checkBitIdenticalToSquare
% the lattice native one sided gradient == the old matrix based one

ebsd = EBSD(mtexdata('twins','silent'));
eG = ebsd.gridify;

% with grainId present too, so the grain boundary masking is exercised
[~,eG2] = calcGrains(eG);

for e = {eG, eG2}

  eg = e{1};
  g = gradient(EBSD(eg),'basis',[eg.d1 eg.d2]);

  assert(isequaln(g(:,1).xyz, reshape(eg.gradient1,[],1).xyz), ...
    'check_gradient: lattice gradient(:,1) is not bit identical to gradient1');
  assert(isequaln(g(:,2).xyz, reshape(eg.gradient2,[],1).xyz), ...
    'check_gradient: lattice gradient(:,2) is not bit identical to gradient2');

end

% and the type is preserved, not degraded to a plain vector3d
g = gradient(EBSD(eG),'basis',[eG.d1 eG.d2]);
assert(isa(g,'SO3TangentVector') && g.tangentSpace == SO3TangentSpace.leftVector, ...
  'check_gradient: the tangent space type/representation was not preserved');

end

% =========================================================================
function checkEdgeAndHoles
% a hole yields NaN and does NOT trigger the backward fallback

cs = crystalSymmetry('m-3m');
pos = makePositions('square axis aligned');
ori = orientation.byAxisAngle(zvector,0.002*pos.x,cs);
ebsd = EBSD(pos,ori,ones(length(pos),1),{cs},struct);
ebsd.unitCell = unitCellOf('square axis aligned');

[~,A] = ebsd.gradient;
a1 = vector3d(A(1,1),A(2,1),0);

% Located by POSITION, not by ebsd.lattice.ij: gradient works in the basis
% orientBasis pins, which may be a permutation/flip of the one lattice
% returns, so the columns of the two do not have to correspond.
lat = ebsd.lattice;
ij = lat.ij;
interior = find(all(ij > min(ij,[],1)+2 & ij < max(ij,[],1)-2, 2), 1);
pHole = ebsd.pos(interior);

% the pixel one step BELOW the hole in a1, i.e. the one whose +a1 neighbour
% is about to disappear
src = find(norm(ebsd.pos - (pHole - a1)) < 1e-9, 1);
assert(~isempty(src), 'check_gradient: could not locate the pixel below the hole');

gBefore = ebsd.gradient;
assert(~isnan(gBefore(src,1)), ...
  'check_gradient: that pixel was already NaN before the hole was made');

keep = true(length(ebsd),1); keep(interior) = false;
holed = ebsd.subSet(keep);

% subSet renumbers, so find it again by position
src2 = find(norm(holed.pos - (pHole - a1)) < 1e-9, 1);
gh = holed.gradient;

assert(isnan(gh(src2,1)), ...
  ['check_gradient: a pixel whose forward neighbour is a hole must be NaN, ' ...
  'not fall back to the backward difference']);

end

% =========================================================================
function checkLeastSquaresOnLinear
% on an exactly linear field every stencil agrees, on square and on hex
%
% Any stencil with two independent directions fits a linear field exactly,
% so this pins that all three implement the same derivative - it cannot,
% by construction, tell the stencils apart. checkStencilChoice does that.

cs = crystalSymmetry('m-3m');

for geom = {'square rotated 30','hex'}

  pos = makePositions(geom{1});
  ori = orientation.byAxisAngle(zvector,0.002*pos.x + 0.001*pos.y,cs);
  ebsd = EBSD(pos,ori,ones(length(pos),1),{cs},struct);
  ebsd.unitCell = unitCellOf(geom{1});

  inner = interiorMask(ebsd);
  g1 = ebsd.gradient;

  for st = {'oneSided','1hop','full'}

    g2 = ebsd.gradient('stencil',st{1});
    d = max(norm(vector3d(g1(inner,:)) - vector3d(g2(inner,:))),[],'all');

    assert(d < 1e-8, ...
      ['check_gradient: %s - the ''%s'' stencil differs from one sided by ' ...
       '%.3g on an exactly linear field, where every stencil must be exact'], ...
      geom{1}, st{1}, d);

  end

  % the documented alias
  gA = ebsd.gradient('leastSquares');
  gH = ebsd.gradient('stencil','1hop');
  ok = ~isnan(gA) & ~isnan(gH);
  assert(isequaln(isnan(gA),isnan(gH)) && ...
      max(norm(vector3d(gA(ok)) - vector3d(gH(ok))),[],'all') < 1e-14, ...
    'check_gradient: %s - ''leastSquares'' is not the same as ''1hop''',geom{1});

end

end

% =========================================================================
function checkStencilChoice
% the three stencils really are three different neighbourhoods
%
% The linear field check above passes for any of them, so on its own it
% would not notice the stencil being ignored, or reverting to the hardcoded
% six offset list that made 'leastSquares' asymmetric on a square grid
% (4 axial plus TWO of the four diagonals - see EBSD/gradient).
%
% Two things are pinned: coverage is strictly ordered, and the two diagonal
% pairs are treated alike.
%
% NB rotating the whole map does NOT test the second one. The stencil lives
% in lattice index space and latticeBasis re-derives the basis from the
% rotated unit cell, so the map and its lattice frame turn together and the
% NaN pattern is invariant for any stencil whatsoever - the old asymmetric
% list passes that test unchanged. What does discriminate is removing one
% diagonal pair or the other from an otherwise singular pixel: a stencil
% using (1,-1),(-1,1) but not (1,1),(-1,-1) rescues the pixel in one case
% and not in the mirrored one.

cs = crystalSymmetry('m-3m');
pos = makePositions('square axis aligned');
ori = orientation.byAxisAngle(zvector,0.002*pos.x + 0.001*pos.y,cs);

% Deliberately isolate one pixel along a line. makePositions lays the grid
% out as ndgrid(0:n-1,0:n-1) with x from j and y from i, so the linear index
% of (i,j) is i + j*n + 1. Removing the two j-neighbours of the target
% leaves it with only its two i-neighbours, which are collinear - so the
% 1hop fit is singular there and yields NaN, while 'full' still has the four
% diagonals and solves it. Punching random holes does not achieve this: with
% 4 axial neighbours a pixel stays solvable unless it loses a whole
% direction.
n0 = 25; ind = @(i,j) i + j*n0 + 1;
target = [12 12];

keep = true(length(pos),1);
keep(ind(target(1),target(2)-1)) = false;
keep(ind(target(1),target(2)+1)) = false;

ebsd = EBSD(pos(keep),ori(keep),ones(nnz(keep),1),{cs},struct);
ebsd.unitCell = unitCellOf('square axis aligned');

% Now the two mirrored configurations. Both keep the target singular in its
% axial directions; one removes the main diagonal neighbours (+d,+d),
% (-d,-d), the other the anti diagonal (+d,-d), (-d,+d). x runs with j and y
% with i, so (+d,+d) is (i+1,j+1) and (+d,-d) is (i-1,j+1).
st = {'oneSided','1hop','full'};

mainDiag = [ind(target(1)+1,target(2)+1), ind(target(1)-1,target(2)-1)];
antiDiag = [ind(target(1)-1,target(2)+1), ind(target(1)+1,target(2)-1)];

% this one first: it is the specific claim, and it is the assertion the old
% asymmetric stencil violates
for k = 2:3

  nDrop = zeros(1,2); drop = {mainDiag,antiDiag};

  for c = 1:2
    kp = keep;
    kp(drop{c}) = false;
    e = EBSD(pos(kp),ori(kp),ones(nnz(kp),1),{cs},struct);
    e.unitCell = unitCellOf('square axis aligned');
    nDrop(c) = nnz(isnan(e.gradient('stencil',st{k})));
  end

  assert(nDrop(1) == nDrop(2), ...
    ['check_gradient: the ''%s'' stencil treats the two diagonals ' ...
     'differently - dropping the main diagonal leaves %d NaN, dropping the ' ...
     'anti diagonal %d. A stencil must use either both pairs or neither.'], ...
    st{k}, nDrop(1), nDrop(2));

end

% and the coverage ordering
n = zeros(1,3);
for k = 1:3, n(k) = nnz(isnan(ebsd.gradient('stencil',st{k}))); end

assert(n(1) > n(2) && n(2) > n(3), ...
  ['check_gradient: the stencils should be strictly ordered in coverage, ' ...
   'got oneSided %d, 1hop %d, full %d'], n(1), n(2), n(3));

end

% =========================================================================
function checkOffPlaneMap
% a map whose normal is not z - gradient, gradientDir and curvature
%
% latticeBasis used to read the unit cell as (x,y), so a map in the xz plane
% collapsed to a singular basis, A = [d 0; 0 0], and gradient/curvature died
% inside assignGridIndex with "Array indices must be positive integers".
% Everything geometric is now done in the map plane frame (ebsd.rot2Plane).
%
% The statement checked is equivariance: turning the map and asking along a
% turned direction must give the turned answer. That is stronger than any
% single number, and it is checked on the DIRECTIONAL derivatives rather
% than on the tensor, for two reasons. gradient() reports along the two
% lattice directions and orientBasis re-pins which of them is a1 when the
% map turns in plane, so its columns are not equivariant by label. And the
% tensor carries a NaN column, which rotate() then smears over every entry -
% NaN*0 is NaN - so comparing rotated tensors is vacuously true.

cs = crystalSymmetry('m-3m');
pos = makePositions('square axis aligned');
ori = orientation.byAxisAngle(zvector,0.002*pos.x + 0.0035*pos.y,cs);
ebsd = EBSD(pos,ori,ones(length(pos),1),{cs},struct);
ebsd.unitCell = unitCellOf('square axis aligned');

gX = vector3d(ebsd.gradientX);
gY = vector3d(ebsd.gradientY);

% 90 degree about x: the map plane normal goes z -> -y, so the in plane
% directions become x and z, and y leaves the plane
rot = rotation.byAxisAngle(xvector,90*degree);
ebsdR = rotate(ebsd,rot);

assert(isnull(angle(ebsdR.N,-vector3d.Y)), ...
  'check_gradient: rotating the map did not carry its normal, N = %s', ...
  char(ebsdR.N));

% the lattice must still be a lattice
A = ebsdR.lattice.A;
assert(abs(det(A)) > 1e-12, ...
  ['check_gradient: the lattice basis of an off plane map is singular, ' ...
   'A = %s - latticeBasis is reading the unit cell as (x,y)'], mat2str(A,3));

% equivariance of the two in plane directions
pairs = {vector3d.X, gX, 'gradientX'; vector3d.Z, gY, 'gradientY'};

for p = 1:2

  got = vector3d(gradientDirPublic(ebsdR,pairs{p,1}));
  ref = reshape(rot * pairs{p,2}, size(pairs{p,2}));

  ok = ~isnan(got) & ~isnan(ref);
  assert(nnz(ok) > 0.5*numel(ok), ...
    'check_gradient: too little of the off plane gradient is defined');

  d = max(norm(got(ok) - ref(ok)));
  assert(d < 1e-10, ...
    ['check_gradient: the off plane map is not equivariant - the rotated ' ...
     '%s differs from the rotation of %s by %.3g'], ...
    pairs{p,3}, pairs{p,3}, d);

end

% and the direction that has left the plane has no answer
assert(all(isnan(ebsdR.gradientY)), ...
  ['check_gradient: gradientY must be NaN once y is out of the map plane, ' ...
   'the same way gradientZ is for an xy map']);

% curvature: assembled from the in plane directions, unknown along N. N is
% -y here, so it is the SECOND column that is unknown, not the third
kappa = ebsdR.curvature;
fin = @(j) nnz(~isnan(kappa{1,j}));

assert(fin(2) == 0, ...
  'check_gradient: curvature column 2 should be unknown for N = -y, %d finite', fin(2));
assert(fin(1) > 0 && fin(3) > 0, ...
  ['check_gradient: curvature columns 1 and 3 should be known for N = -y, ' ...
   'got %d and %d finite'], fin(1), fin(3));

% the xy case still puts it in column 3
kappa0 = ebsd.curvature;
assert(nnz(~isnan(kappa0{1,3})) == 0 && nnz(~isnan(kappa0{1,1})) > 0, ...
  'check_gradient: for a map in the xy plane column 3 must be the unknown one');

end

% =========================================================================
function g = gradientDirPublic(ebsd,w)
% gradientDir is private to @EBSD, so reach it through the public wrappers

if isnull(angle(w,vector3d.X))
  g = ebsd.gradientX;
elseif isnull(angle(w,vector3d.Y))
  g = ebsd.gradientY;
else
  g = ebsd.gradientZ;
end

end

% =========================================================================
function pos = makePositions(geom)

n = 25; dxy = 0.5;
[i,j] = ndgrid(0:n-1, 0:n-1);

switch geom
  case 'square axis aligned'
    pos = vector3d(dxy*j(:), dxy*i(:), 0);
  case 'square rotated 30'
    pos = rotate(vector3d(dxy*j(:), dxy*i(:), 0), rotation.byAxisAngle(zvector,30*degree));
  case 'square rotated 45'
    pos = rotate(vector3d(dxy*j(:), dxy*i(:), 0), rotation.byAxisAngle(zvector,45*degree));
  case 'square sheared'
    pos = vector3d(dxy*(j(:) + 0.3*i(:)), dxy*i(:), 0);
  case 'hex'
    x = dxy*(j(:) + 0.5*mod(i(:),2));
    y = dxy*sqrt(3)/2*i(:);
    pos = vector3d(x,y,0);
end

end

% =========================================================================
function uC = unitCellOf(geom)

dxy = 0.5;
switch geom
  case 'square axis aligned'
    uC = dxy*0.5*vector3d([-1 1 1 -1],[-1 -1 1 1],0);
  case 'square rotated 30'
    uC = rotate(dxy*0.5*vector3d([-1 1 1 -1],[-1 -1 1 1],0), ...
      rotation.byAxisAngle(zvector,30*degree));
  case 'square rotated 45'
    uC = rotate(dxy*0.5*vector3d([-1 1 1 -1],[-1 -1 1 1],0), ...
      rotation.byAxisAngle(zvector,45*degree));
  case 'square sheared'
    uC = 0.5*(vector3d(dxy,0,0)*[-1 1 1 -1] + vector3d(0.3*dxy,dxy,0)*[-1 -1 1 1]);
  case 'hex'
    omega = (0:60:300)*degree + 30*degree;
    uC = (dxy/sqrt(3)) * vector3d(cos(omega),sin(omega),0);
end

end

% =========================================================================
function inner = interiorMask(ebsd)
% pixels at least 2 lattice steps away from the border of the index box

ij = ebsd.lattice.ij;
lo = min(ij,[],1) + 2; hi = max(ij,[],1) - 2;
inner = all(ij >= lo & ij <= hi, 2);

end

% =========================================================================
function checkShapeFollowsInput
% gradientX/Y/Z come back in the shape of the data they were given
%
% A gridded map must give a map shaped gradient, and with it a map shaped
% curvature tensor, so kappa(2,3) addresses the pixel in row 2, column 3 -
% which is what the matrix based @EBSDsquare/gradientX allowed and what
% doc/Plasticity/GND.m demonstrates. The lattice version returns a column
% naturally, so it has to reshape.

e = EBSD(mtexdata('twins','silent'));
eG = e.gridify;

assert(isequal(size(eG.gradientX),size(eG)), ...
  'check_gradient: gridded gradientX is %s, expected the map shape %s', mat2str(size(eG.gradientX)), mat2str(size(eG)));

k = eG.curvature;
assert(isequal(size(k),size(eG)), ...
  'check_gradient: gridded curvature is %s, expected the map shape %s', mat2str(size(k)), mat2str(size(eG)));

% and it is addressable by pixel
k23 = k(2,3); %#ok<NASGU>

% a plain list stays a list, and the values do not depend on either
ep = EBSD(eG);
assert(isequal(size(ep.gradientX),[length(ep) 1]), ...
  'check_gradient: a plain EBSD gave a gradientX of %s, expected a column', mat2str(size(ep.gradientX)));

a = k.M(:); b = ep.curvature.M(:);
f = isfinite(a) & isfinite(b);
assert(max(abs(a(f)-b(f))) == 0, ...
  'check_gradient: gridded and plain curvature differ by %g', max(abs(a(f)-b(f))));

end
