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
% Also owns what the axis ends up showing: the surf backend paints the whole
% lattice raster, padding cells included, so the axis limits must not simply
% follow the graphics.
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
checkPaddedAxisLimits;

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

  % rgb scales the alpha by (1 - min(rgb)), a scalar field by data/max(data)
  expected = alphaMap(:) .* (1 - min(rgbList,[],2));
  assert(max(abs(alphaData{3} - expected)) < 1e-12, ...
    'check_ebsdMapBackends: %s grid, rgb data did not take the rgb transparency branch', grid{1});

end

end

% =========================================================================
function checkPaddedAxisLimits
% the map is trimmed to the measurements, not to the raster around them
%
% A lattice rotated against the map axes - mtexdata sharp - needs padding
% far outside the measured region to close its rectangular raster. The surf
% backend paints that raster as one surface, with the padding cells merely
% coloured NaN, so 'axis tight' followed the padding and left the map a
% small island in a much larger white box: 200 x 100 of measurements inside
% a 300 x 300 axis. The limits have to come from EBSD/extent, widened by the
% unit cell that is drawn around every position.

ebsd = makeRotatedLatticeMap;

for what = {'as a list','gridified'}

  if strcmp(what{1},'gridified'), ebsd = ebsd.gridify; end

  pos = ebsd.pos;
  raster = [min(pos.x(:)) max(pos.x(:)) min(pos.y(:)) max(pos.y(:))];
  ext = ebsd.extent;
  uC = ebsd.unitCell;
  expect = ext(1:4) + [min(uC.x) max(uC.x) min(uC.y) max(uC.y)];

  close all
  plot(ebsd,ebsd.orientations)
  lim = [xlim ylim];

  assert(max(abs(lim - expect)) < 1e-10, ...
    'check_ebsdMapBackends: %s, the axis is %s, expected the measured %s', ...
    what{1}, mat2str(lim,4), mat2str(expect,4));

  % once gridified the padding is part of the object and must stay out
  if strcmp(what{1},'gridified')
    assert(raster(1) < lim(1) && raster(2) > lim(2), ...
      'check_ebsdMapBackends: %s, the padded raster %s should exceed the axis %s', ...
      what{1}, mat2str(raster,4), mat2str(lim,4));
  end

  % the surface still covers the raster - it is the corners that no measured
  % cell touches that are dropped, which is what keeps them out of the limits
  hS = findobj(gca,'type','surface');
  assert(numel(hS)==1,'check_ebsdMapBackends: %s, expected one surface',what{1});
  assert(any(isnan(hS.XData(:))), ...
    'check_ebsdMapBackends: %s, no corner was dropped from the surface',what{1});
  assert(abs(min(hS.XData(:))-lim(1)) < 1e-10 && ...
    abs(max(hS.XData(:))-lim(2)) < 1e-10, ...
    'check_ebsdMapBackends: %s, the surface spans %s, the axis %s', ...
    what{1}, mat2str([min(hS.XData(:)) max(hS.XData(:))],4), mat2str(lim(1:2),4));

end

end

% =========================================================================
function ebsd = makeRotatedLatticeMap
% a map on a lattice rotated against the map axes, as in mtexdata sharp
%
% Rows 2 apart in x, each row shifted by (-0.5,-0.5) against the one above,
% cut to a rectangle. The shortest lattice vectors are then (0.5,0.5) and
% (1,-1), so the rectangle is a diamond in lattice indices and gridify has
% to pad well outside it.

nRow = 12; xMax = 10;

x = []; y = [];
for j = 0:nRow-1
  xj = mod(-0.5*j,2):2:xMax;
  x = [x, xj]; y = [y, -0.5*j*ones(size(xj))]; %#ok<AGROW>
end

ebsd = EBSD(vector3d(x(:),y(:),0), rotation.rand(numel(x),1), ...
  ones(numel(x),1), {'notIndexed',crystalSymmetry('m-3m')}, struct());

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
