function check_gridify
% check that ebsd.gridify picks the right grid type and does not distort pos
%
% A hexagonal unit cell must end up as an @EBSDhex, a square one as an
% @EBSDsquare. Regression: ebsd.unitCell became a 1xN @vector3d, so the
% shape test size(unitCell,1)==6 that dispatched to hexify never fired and
% every hex map was squarified onto the lattice basis (a1,a2) with a2 at
% 120 degree - a parallelogram, which sheared ebsd.pos far outside the
% measured extent (ferrite: x in [-40.2, 110.25] instead of [0, 69.9]).

cases = {'ferrite','EBSDhex',6; 'titanium','EBSDhex',6; ...
  'twins','EBSDsquare',4; 'forsterite','EBSDsquare',4};

for k = 1:size(cases,1)

  name = cases{k,1};
  ebsd = EBSD(mtexdata(name,'silent'));

  assert(length(ebsd.unitCell) == cases{k,3}, ...
    'check_gridify: %s is expected to have a %d corner unit cell',name,cases{k,3});

  [ebsdGrid,newId] = ebsd.gridify;

  assert(isa(ebsdGrid,cases{k,2}), ...
    'check_gridify: %s gridified to %s, expected %s',name,class(ebsdGrid),cases{k,2});

  % every measurement keeps its position - up to the grid regularisation
  dPos = max(norm(ebsd.pos - ebsdGrid.pos(newId)));
  assert(dPos < 0.05 * ebsd.dPos, ...
    'check_gridify: %s moves measurements by %g (step size %g)',name,dPos,ebsd.dPos);

  % no two measurements share a grid point
  assert(numel(unique(newId)) == numel(newId), ...
    'check_gridify: %s maps several measurements onto the same grid point',name);

  % the grid does not extend more than one cell beyond the measured extent
  ext = ebsd.extent; extGrid = ebsdGrid.extent;
  assert(all(abs(extGrid(1:4) - ext(1:4)) <= ebsd.dPos), ...
    'check_gridify: %s grid extent [%s] does not match data extent [%s]',...
    name,xnum2str(extGrid(1:4)),xnum2str(ext(1:4)));

  % gridifying an already gridified map is a no-op
  ebsdGrid2 = ebsdGrid.gridify;
  assert(isa(ebsdGrid2,cases{k,2}) && all(size(ebsdGrid2) == size(ebsdGrid)) && ...
    max(norm(ebsdGrid.pos(:) - ebsdGrid2.pos(:))) < 1e-10, ...
    'check_gridify: %s is not stable under a second gridify',name);

  % column major layout: one scan row per matrix row, coordinates increasing
  assert(range(ebsdGrid.pos(1,:).y) < 1e-6 * ebsd.dPos, ...
    'check_gridify: %s does not have a constant y along the first matrix row',name);
  assert(ebsdGrid.pos(end,1).y > ebsdGrid.pos(1,1).y && ...
    ebsdGrid.pos(1,end).x > ebsdGrid.pos(1,1).x, ...
    'check_gridify: %s is not oriented towards increasing coordinates',name);

end

checkLayout;
checkMapShapedInput;
checkDistortedGrid;
checkResample;
checkResampleRotated;

disp('gridify: all checks passed');

end

% =========================================================================
function checkLayout
% the rowMajor layout is the transpose of the default columnMajor one

ebsd = EBSD(mtexdata('twins','silent'));

eC = ebsd.gridify;
eR = ebsd.gridify('rowMajor');

assert(all(size(eC) == fliplr(size(eR))), ...
  'check_gridify: rowMajor is not the transpose of columnMajor');

assert(abs(dot(normalize(eC.d1),yvector)-1) < 1e-6 && ...
  abs(dot(normalize(eC.d2),xvector)-1) < 1e-6, ...
  'check_gridify: columnMajor does not run along +y, +x');

assert(abs(dot(normalize(eR.d1),xvector)-1) < 1e-6 && ...
  abs(dot(normalize(eR.d2),yvector)-1) < 1e-6, ...
  'check_gridify: rowMajor does not run along +x, +y');

assert(isequaln(eC.rotations.a, eR.rotations.a.') && ...
  isequaln(reshape(eC.phaseId,size(eC)), reshape(eR.phaseId,size(eR)).'), ...
  'check_gridify: rowMajor and columnMajor do not hold the same data');

% the explicit flag agrees with the default
assert(all(size(ebsd.gridify('columnMajor')) == size(eC)), ...
  'check_gridify: columnMajor is not the default layout');

end

% =========================================================================
function checkMapShapedInput
% gridify works on an EBSD whose pos was handed over map shaped (r x c)
%
% Regression: calcMesh compared an explicitly flattened ideal grid against
% pos in whatever shape the caller had passed. With a map shaped pos that
% subtraction is (N x 1) minus (r x c), which used to hang forever in
% vector3d/plus and errors since then - although nothing in the algorithm
% cares how the caller shaped its input.

sz = 20; d = 0.3;
[Y,X] = ndgrid((0:sz-1)*d,(0:sz-1)*d);

ebsd = EBSD(vector3d(X,Y,zeros(sz)), rotation.rand(sz,sz), ones(sz,sz), ...
  {crystalSymmetry('m-3m')}, struct('bc',rand(sz,sz)));

[ebsdGrid,newId] = ebsd.gridify;

assert(numel(ebsdGrid) == sz^2, ...
  'check_gridify: a map shaped pos gridified to %d instead of %d points',...
  numel(ebsdGrid),sz^2);

assert(max(norm(ebsdGrid.pos(newId) - ebsd.pos(:))) < 1e-10 * d, ...
  'check_gridify: a map shaped pos does not survive gridify');

end

% =========================================================================
function checkDistortedGrid
% a distorted map keeps every measurement at its measured position
%
% A distortion beyond calcMesh's 1e-2 tolerance takes its second branch,
% which interpolates the deformation field and then restores the observed
% nodes. Regression: that restore assigned through the logical mask of
% known nodes, which fills in ascending linear index order, while pos comes
% in the callers order - so on any map whose scan order is not the mesh's
% column major order the positions ended up permuted (by up to a full map
% width on twins). The ideal-grid branch every undistorted map takes never
% reaches this line.

ebsd = EBSD(mtexdata('twins','silent'));

% trapezoidal stage drift: scale x per scan row about the map centre
p = ebsd.pos;
xC = (min(p.x) + max(p.x))/2;
yC = (min(p.y) + max(p.y))/2; yHalf = (max(p.y) - min(p.y))/2;
ebsd.pos = vector3d(xC + (p.x-xC).*(1 + 0.05*(p.y-yC)/yHalf), p.y, p.z);

[ebsdGrid,newId] = ebsd.gridify;

assert(max(norm(ebsdGrid.pos(newId) - ebsd.pos)) < 1e-10 * ebsd.dPos, ...
  'check_gridify: a distorted map does not keep its measured positions');

end

% =========================================================================
function checkResample
% a custom unit cell resamples the map onto a grid of exactly that cell

ebsd = EBSD(mtexdata('copper','silent'));

uC = 2.5 * vector3d([-1 -1 1 1].',[-1 1 1 -1].',0);
ebsdS = ebsd.gridify('unitCell',uC);

assert(isa(ebsdS,'EBSDsquare'), ...
  'check_gridify: a square unit cell did not produce an EBSDsquare');

assert(max(norm(ebsdS.unitCell(:) - uC(:))) < 1e-6 * norm(uC(1)), ...
  'check_gridify: the resampled map does not carry the requested unit cell');

% the new grid covers the old map without extending it
ext = ebsd.extent; extS = ebsdS.extent;
assert(all(abs(extS(1:4) - ext(1:4)) <= ebsd.dPos), ...
  'check_gridify: the resampled grid extent [%s] does not match [%s]',...
  xnum2str(extS(1:4)),xnum2str(ext(1:4)));

% the resampled map is not empty - nearest neighbor interpolation assigns
% every grid point inside the map
assert(nnz(ebsdS.isIndexed) > 0.9 * length(ebsdS), ...
  'check_gridify: only %d of %d resampled pixels are indexed',...
  nnz(ebsdS.isIndexed),length(ebsdS));

% and it is plottable - a degenerate unit cell would break latticeBasis
f = figure('visible','off');
plot(ebsdS('indexed'),ebsdS('indexed').orientations);
close(f);

end

% =========================================================================
function checkResampleRotated
% a rotated unit cell gives a rotated - and still gap free - grid
%
% Regression: the new grid was built axis aligned from the BOUNDING BOX of
% the unit cell instead of from its cell to cell translations. A unit cell
% rotated by 45 degree was therefore placed at a spacing of its full
% diagonal, so the cells only touched at their corners and half the map -
% every second cell of a checkerboard - stayed empty.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

uC = rotate(2*ebsd.unitCell,45*degree);
ebsdR = ebsd.gridify('unitCell',uC);

% the grid directions follow the unit cell, they are not axis aligned
assert(abs(abs(dot(normalize(ebsdR.d1),yvector)) - cos(45*degree)) < 1e-6 && ...
  abs(abs(dot(normalize(ebsdR.d2),xvector)) - cos(45*degree)) < 1e-6, ...
  'check_gridify: a 45 degree rotated unit cell did not give a rotated grid');

% neighbouring cells are one cell edge apart, not one bounding box apart
dCell = norm(uC(1) - uC(2));
assert(abs(norm(ebsdR.d1) - dCell) < 1e-6 * dCell && ...
  abs(norm(ebsdR.d2) - dCell) < 1e-6 * dCell, ...
  'check_gridify: the rotated grid has spacing %g / %g instead of %g',...
  norm(ebsdR.d1),norm(ebsdR.d2),dCell);

% hence the new cells cover the original map instead of only half of it
areaNew = nnz(ebsdR.isIndexed) * polyArea(uC);
areaOld = nnz(ebsd.isIndexed) * polyArea(ebsd.unitCell);
assert(areaNew > 0.95 * areaOld, ...
  'check_gridify: the rotated grid covers only %.0f%% of the map',...
  100 * areaNew / areaOld);

end
