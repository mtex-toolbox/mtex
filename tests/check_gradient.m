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
% on an exactly linear field the one sided and the least squares form agree

cs = crystalSymmetry('m-3m');
pos = makePositions('square rotated 30');
ori = orientation.byAxisAngle(zvector,0.002*pos.x + 0.001*pos.y,cs);
ebsd = EBSD(pos,ori,ones(length(pos),1),{cs},struct);
ebsd.unitCell = unitCellOf('square rotated 30');

g1 = ebsd.gradient;
g2 = ebsd.gradient('leastSquares');

inner = interiorMask(ebsd);
d = max(norm(vector3d(g1(inner,:)) - vector3d(g2(inner,:))),[],'all');

assert(d < 1e-8, ...
  ['check_gradient: one sided and least squares differ by %.3g on an ' ...
  'exactly linear field, where both must be exact'], d);

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
