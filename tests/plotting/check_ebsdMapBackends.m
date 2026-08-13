function check_ebsdMapBackends
% checks on the backends behind plot(ebsd,data) - patch, imagesc, surf
%
% Owns the shape contract at the boundary between an @EBSD map and the
% graphics object it becomes. Everything a caller hands over per pixel -
% the data, an rgb colour, a 'faceAlpha' - may arrive either as a flat list
% or with the shape of the map, since a gridded @EBSD stores its per pixel
% properties as the (r x c) matrix. The graphics object wants columns, so
% each backend has to flatten, and it has to flatten every one of them.
%
% Regression: plotPatch reshaped the colour data and not the alpha, so
% plot(ebsd,color,'faceAlpha',alpha) on a gridded map died with "Arrays have
% incompatible sizes" (doc/EBSDAnalysis/EBSDGROD.m). It also decided rgb vs
% scalar with size(d,2)==3 on the UNRESHAPED data, where the second
% dimension is the number of map columns - that one is silent, it just
% applies the scalar transparency formula to rgb data.
%
% See also
% EBSD/plotUnitCells EBSD/plot

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanup = onCleanup(@() set(0,'DefaultFigureVisible',oldVis)); %#ok<NASGU>

checkAlphaShapes;

close all
disp('check_ebsdMapBackends: passed');

end

% =========================================================================
function checkAlphaShapes
% a per pixel alpha is accepted map shaped and as a column, and means the same

for grid = {'square','hex'}

  ebsd = makeMap(grid{1});
  n = numel(ebsd);

  % a scalar field and an rgb colour, each in both shapes
  scalarMap = reshape(linspace(0,1,n),size(ebsd));
  rgbList   = repmat(linspace(0,1,n).',1,3);
  alphaMap  = reshape(linspace(0,1,n),size(ebsd));

  cases = { ...
    'scalar data, map shaped alpha', scalarMap,      alphaMap; ...
    'scalar data, column alpha',     scalarMap(:),   alphaMap(:); ...
    'rgb data, map shaped alpha',    rgbList,        alphaMap; ...
    'rgb data, column alpha',        rgbList,        alphaMap(:)};

  alphaData = cell(size(cases,1),1);

  for k = 1:size(cases,1)

    close all
    h = plot(ebsd,cases{k,2},'faceAlpha',cases{k,3},'backend','patch');

    a = get(h,'FaceVertexAlphaData');
    assert(isequal(size(a),[n 1]), ...
      'check_ebsdMapBackends: %s grid, %s gave FaceVertexAlphaData %s, expected [%d 1]', ...
      grid{1}, cases{k,1}, mat2str(size(a)), n);

    alphaData{k} = a;

  end

  % the two shapes of the same quantity must not merely both work - they
  % have to produce the same picture
  assert(isequal(alphaData{1},alphaData{2}), ...
    'check_ebsdMapBackends: %s grid, a map shaped alpha and its column differ for scalar data', grid{1});
  assert(isequal(alphaData{3},alphaData{4}), ...
    'check_ebsdMapBackends: %s grid, a map shaped alpha and its column differ for rgb data', grid{1});

  % and the rgb branch has to be the rgb branch: for rgb the alpha is scaled
  % by (1 - min(rgb)), for a scalar field by data/max(data). Those disagree
  % here, which is what makes the check meaningful.
  expected = alphaMap(:) .* (1 - min(rgbList,[],2));
  assert(max(abs(alphaData{3} - expected)) < 1e-12, ...
    'check_ebsdMapBackends: %s grid, rgb data did not take the rgb transparency branch', grid{1});

end

end

% =========================================================================
function ebsd = makeMap(type)
% a small gridded map of the requested grid type

cs = crystalSymmetry('m-3m');
n = 6;

if strcmp(type,'square')
  ebsd = EBSDsquare([],rotation.rand(n,n),ones(n*n,1),[0 1], ...
    {'notIndexed',cs},'dxy',[1 1]);
else
  [c,r] = meshgrid(0:n-1,0:n-1);
  x = c + mod(r,2)*0.5;
  y = r*sqrt(3)/2;
  ebsd = EBSD(vector3d(x(:),y(:),0),rotation.rand(n*n,1),ones(n*n,1), ...
    {'notIndexed',cs},struct()).gridify;
end

end
