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

end

disp('gridify: all checks passed');

end
