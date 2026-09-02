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
%  GridType       - [automatic, hexagonal, rectangular, circle]
%  GridResolution - step size of the grid, either dx or [dx dy]
%  GridRotation   - rotation of the unit cell against the x axis
%
% Description
% Without options the cell is estimated from the positions alone. Each
% option overrides exactly the quantity it names and leaves the remaining
% ones to the estimate, so |'GridResolution',5| on a hexagonal point set
% returns a hexagon of size 5 in the orientation that was detected.

% nothing to do -> skip
if isempty(xy)
  unitCell = [];
  return;
elseif size(xy,2) == 3
  xy = xy(:,1:2);
end

% estimate size, shape and rotation of the cell from the positions ...
[unitCell,dxy,cellRot] = estimateUnitCell(xy);

% ... and let the options overrule what they name
unitCell = applyGridOptions(unitCell,dxy,cellRot,varargin{:});


% =========================================================================
% the unit cell as it follows from the positions alone, together with its size
% [dx dy] and rotation, which cannot be read back off a scaled cell
function [unitCell,dxy,cellRot] = estimateUnitCell(xy)

cellRot = 0;

% first estimate of the grid resolution - very rough idea
area = (max(xy(:,1))-min(xy(:,1)))*(max(xy(:,2))-min(xy(:,2)));
dxy = sqrt(area / length(xy));

% compensate for single line EBSD
if dxy == 0
  lx = mean(diff(xy(:,1))); ly = mean(diff(xy(:,2)));
  if lx==0, lx=ly; else; ly=lx; end
  dxy = (lx+ly)/2;
end

if ~(dxy > 0)
  unitCell = regularPoly(4,1,0);
  dxy = [1 1];
  return
end

% second estimate of the grid resolution
% works good for square grids that are not rotated
xyEst = subSample(xy,10000);
dxy2 = [mean(diff(uniquetol(xyEst(:,1),dxy(1)/100,'DataScale',1))),...
  mean(diff(uniquetol(xyEst(:,2),dxy(end)/100,'DataScale',1)))];

% a single scan line is constant in one coordinate, take the spacing from the other
if any(isnan(dxy2))
  if all(isnan(dxy2)), dxy2(:) = dxy(1); else, dxy2(isnan(dxy2)) = dxy2(~isnan(dxy2)); end
end

% check for square grid
% (use a tolerance, the coordinates may be rotated)
col = xy(abs(xy(:,1)-xy(2,1)) < dxy2(1)*1e-3, 2);
row = xy(abs(xy(:,2)-xy(2,2)) < dxy2(2)*1e-3, 1);
if numel(col) > 1 && numel(row) > 1 && ...
    abs(dxy2(1) - dxy2(2))/min(dxy2) <  1e-3 && ...
    abs((min(diff(uniquetol(col,'DataScale',1))) - dxy2(2))/dxy2(2)) < 0.01 && ...
    abs((min(diff(uniquetol(row,'DataScale',1))) - dxy2(1))/dxy2(1)) < 0.01
  unitCell = regularPoly(4,dxy2,0);
  dxy = dxy2;
  return
end

% maybe it is a grid after all, just rotated - much cheaper than a Voronoi
[unitCell,dxy,cellRot] = detectLattice(xy);
if ~isempty(unitCell), return; end
cellRot = 0;


% if we are not sure we make a voronoi decomposition
% with a reduced data set
xySmall = subSample(xy,10000);

% remove duplicates from the coordinates
xySmall = uniquetol(xySmall,0.01/sqrt(size(xy,1)),'ByRows',true);

try
  % compute Voronoi decomposition % TODO: replace by faster version !!
  [v, c] = voronoin(xySmall,{'Qz'});
  
  % compute the area of all Voronoi cells
  areaf = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));
  areaf = cellfun(@(c1) areaf(v([c1 c1(1)],1),v([c1 c1(1)],2)),c);
  
  % the unit cell should be the Voronoi cell with the smallest area
  areaf(areaf < quantile(areaf,0.8)/100) = inf;
  [~, ci] = quantile(areaf,0.05);
  %[~, ci] = min(areaf);
  
  % compute vertices of the unit cell
  unitCell = [v(c{ci},1) - xySmall(ci,1),v(c{ci},2) - xySmall(ci,2)];
  % unitCell = [v(c{ci},1),v(c{ci},2)];
  % sometimes it happens that we have one point doubled, remove those
  ignore = [false;sqrt(sum(diff(unitCell,1).^2,2)) < max(sqrt(sum(diff(unitCell,1).^2,2)))/5];
  unitCell(ignore,:) = [];
    
  % third estimate of the grid resolution, as [dx dy] in the convention of regularPoly
  dxy2 = vecnorm(unitCell,2,1);
catch
  unitCell = [];
end

dxy = dxy2;

%if 100*dxy3 > dxy2, dxy = dxy2; end

if ~isempty(unitCell) && isRegularPoly(unitCell)
  % a Voronoi cell is a genuine polygon, so its rotation has to be read
  % back off its vertices - regularPoly puts the first one at pi/s + rot
  cellRot = atan2(unitCell(1,2),unitCell(1,1)) - pi/size(unitCell,1);
  return
end

% otherwise take a regular unit cell of the estimated size, keeping the
% shape the Voronoi cell had - and a rectangle if there was no cell at all
if size(unitCell,1) == 6
  unitCell = regularPoly(6,dxy,0);
else
  unitCell = regularPoly(4,dxy,0);
end


% =========================================================================
% replace the quantities the user specified and keep the estimate for the others
function unitCell = applyGridOptions(unitCell,dxy,cellRot,varargin)

dxyOpt = get_option(varargin,'GridResolution',[]);
cellType = get_option(varargin,'GridType','');
cellRotOpt = get_option(varargin,'GridRotation',[]);

% nothing specified -> the estimate stands as it is
if isempty(dxyOpt) && isempty(cellType) && isempty(cellRotOpt), return; end

if ~isempty(dxyOpt)
  % a scalar resolution is the same step size in x and y direction
  if isscalar(dxyOpt)
    dxy = [dxyOpt dxyOpt];
  elseif numel(dxyOpt) == 2
    dxy = reshape(dxyOpt,1,2);
  else
    error('MTEX:calcUnitCell:GridResolution',...
      ['The option GridResolution has to be either a scalar step size dx, '...
      'or a pair [dx dy], but %d values were given.'],numel(dxyOpt));
  end
end

if ~isempty(cellRotOpt), cellRot = cellRotOpt; end

if isempty(cellType)
  if size(unitCell,1) == 6
    cellType = 'hexagonal';
  else
    cellType = 'rectangular';
  end
end

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


function isRegular = isRegularPoly(unitCell)

sideLength = sqrt(sum((unitCell).^2,2));
sides      = numel(sideLength);

uC = complex(unitCell(:,1),unitCell(:,2));
nC = uC([2:end 1]);

enclosingAngle = uC./nC;
enclosingAngle = complex(abs(real(enclosingAngle)),...
  abs(imag(enclosingAngle)));

isRegular = any(sides == [4 6]) && ... % norm(sideLength - mean(sideLength))*dxy < 1e-5 && ...
  norm(enclosingAngle - mean(enclosingAngle)) < 0.05*degree;


% detect a possibly rotated square or hex lattice, [] if xy does not look like one
function [unitCell,dxy,rot] = detectLattice(xy)

unitCell = []; dxy = []; rot = 0;

% work on a spatially contiguous chunk, so the local neighbor structure survives
q = subSample(xy,5000);
if size(q,1) < 30, return; end

% 7 nearest neighbors (including self)
[idx,d] = knnsearch(q,q,'K',7);
idx = idx(:,2:end); d = d(:,2:end);

% keep only the true nearest shell (drop 2nd shell picked up for square,
% whose diagonal neighbors sit at sqrt(2)*dxy =~ 1.41*dxy)
med1 = median(d(:,1));
keep = d < 1.25*med1;

nq = size(q,1);
ref = repmat((1:nq)',1,6);
vx = q(idx(keep),1) - q(ref(keep),1);
vy = q(idx(keep),2) - q(ref(keep),2);

len = hypot(vx,vy);
lenSpread = std(len)/median(len);

% doubling the angle identifies v with -v, as MTEX does for antipodal axes
ang2 = mod(2*atan2(vy,vx), 2*pi);

[a2s,ord] = sort(ang2);
lenSorted = len(ord);
n = numel(a2s);
gaps = [diff(a2s); a2s(1) + 2*pi - a2s(end)];
[~,cutAt] = max(gaps);
rotAmount = mod(cutAt,n);
% unwrap the circle at its largest gap so no true cluster straddles the
% array boundary (the wrapped part needs +2*pi to stay monotonic)
a2s = [a2s(rotAmount+1:n); a2s(1:rotAmount) + 2*pi];
lenSorted = lenSorted([rotAmount+1:n, 1:rotAmount]);

% now safe to cluster sequentially
gap = [true; diff(a2s) > 0.2];
clusterId = cumsum(gap);

clustAng2 = accumarray(clusterId,a2s,[],@median);
clustLen  = accumarray(clusterId,lenSorted,[],@median);
clustCount = accumarray(clusterId,1);

% drop tiny/spurious clusters (outliers, far shell)
big = clustCount > 0.1*max(clustCount);
clustAng2 = clustAng2(big); clustLen = clustLen(big);
nClust = numel(clustAng2);

clustAng = mod(clustAng2/2,pi); % back to a single-angle [0,pi) representative

if nClust == 2
  % candidate square lattice - sort by angle, the largest gap is a tie here
  [clustAng,sortOrd] = sort(clustAng);
  clustLen = clustLen(sortOrd);
  dAng = mod(abs(diff(clustAng)),pi);
  dAng = min(dAng, pi-dAng);
  if abs(dAng - pi/2) < 0.08 && abs(diff(clustLen))/mean(clustLen) < 0.05 && lenSpread < 0.12
    dxy = mean(clustLen)*[1 1]; rot = clustAng(1);
    unitCell = regularPoly(4,dxy,rot);
  end
elseif nClust == 3
  % candidate hex lattice: three directions 60 deg apart, equal length
  a = sort(clustAng);
  d1 = mod(a(2)-a(1),pi); d2 = mod(a(3)-a(2),pi); d3 = mod(a(1)-a(3)+pi,pi);
  if all(abs([d1 d2 d3] - pi/3) < 0.08) && ...
      (max(clustLen)-min(clustLen))/mean(clustLen) < 0.05 && lenSpread < 0.12
    dxy = mean(clustLen)*[1 1]; rot = a(1);
    unitCell = regularPoly(6,dxy,rot);
  end
end


% find a square subset of about N points
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
