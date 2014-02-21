function unitCell = calcUnitCell(xy,varargin)
% compute the unit cell for an EBSD data set
%
% Input
%  xy - spatial coordinates
%
% Output
%  unitCell - coordinates of the unit cell
%
% Options
%
% GridType - [automatic, hexagonal, rectangular]

% nothing to do -> skip
if isempty(xy)
  unitCell = [];
  return;
end

% remove dublicates from the coordinates
xy = unique(xy,'first','rows');

if size(xy,2) == 3
  unitCell = [calcUnitCell(xy(:,[1 2]), varargin{:});...
    calcUnitCell(xy(:,[1 3]), varargin{:}); ...
    calcUnitCell(xy(:,[2 3]), varargin{:})];
  return
end

% first estimate of the grid resolution
area = (max(xy(:,1))-min(xy(:,1)))*(max(xy(:,2))-min(xy(:,2)));
dxy = sqrt(area / length(xy));

% reduce data set
xy = subSample(xy,10000);


try
  % compute Voronoi decomposition
  [v, c] = voronoin(xy,{'Qz'});
  
  % compute the area of all Voronoi cells
  areaf = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));
  areaf = cellfun(@(c1) areaf(v([c1 c1(1)],1),v([c1 c1(1)],2)),c);
  
  % the unit cell should be the Voronoi cell with the smalles area
  [a, ci] = min(areaf);
  
  % compute vertices of the unit cell
  unitCell = [v(c{ci},1) - xy(ci,1),v(c{ci},2) - xy(ci,2)];
    
  if isRegularPoly(unitCell,dxy,varargin)
    return
  end
  
  % second estimate of the grid resolution
  dxy2 = min(sqrt(diff(cx).^2 + diff(cy).^2));
  if 100*dxy2 > dxy, dxy = dxy2;end
  
  
catch %#ok<CTCH>
end

% get grid options
dxy = get_option(varargin,'GridResolution',dxy);
cellType = get_option(varargin,'GridType','rectangular');
cellRot = get_option(varargin,'GridRotation',0*degree);

% otherwise take a regular unit cell
switch lower(cellType)
  
  case 'rectangular'
    
    unitCell = regularPoly(4,dxy,cellRot);
    
  case 'hexagonal'
    
    unitCell = regularPoly(6,dxy,cellRot);
    
  case 'circle'
    
    unitCell = regularPoly(16,dxy,cellRot);
    
  otherwise
    
    error('MTEX:plotspatial:UnitCell','Unknown unit cell type!')
end



% a regular polygon with s vertices, diameter d, and rotation rot
function unitCell = regularPoly(s,d,rot)

c = exp(1i*((pi/s:pi/(s/2):2*pi)+rot))*d./sqrt((s/2));
unitCell = [real(c(:)),imag(c(:))];


function isRegular = isRegularPoly(unitCell,dxy,varargin)

sideLength = sqrt(sum((unitCell).^2,2));
sides      = numel(sideLength);

uC = complex(unitCell(:,1),unitCell(:,2));
nC = uC([2:end 1]);

enclosingAngle = uC./nC;
enclosingAngle = complex(abs(real(enclosingAngle)),...
  abs(imag(enclosingAngle)));

isRegular = any(sides == [4 6]) && ... % norm(sideLength - mean(sideLength))*dxy < 1e-5 && ...
  norm(enclosingAngle - mean(enclosingAngle)) < 0.05*degree;


% find a quare subset of about N points
function xy = subSample(xy,N)

xminmax = [min(xy(:,1));max(xy(:,1))];
yminmax = [min(xy(:,2));max(xy(:,2))];

% shrink range until only N points are inside
while length(xy) > N
  
  if diff(xminmax) > diff(yminmax)
    xminmax = [3 1;1 3] * xminmax ./ 4;
  else
    yminmax = [3 1;1 3] * yminmax ./ 4;
  end
  
  xy = xy(xy(:,1)>xminmax(1) & xy(:,1)<xminmax(2) & ...
    xy(:,2)>yminmax(1) & xy(:,2)<yminmax(2),:);
  
end
