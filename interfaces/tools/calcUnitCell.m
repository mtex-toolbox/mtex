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
elseif size(xy,2) == 3
  xy = xy(:,1:2);
end

% maybe everything is given by options
dxy = get_option(varargin,'GridResolution',[]);
cellType = get_option(varargin,'GridType','');
cellRot = get_option(varargin,'GridRotation',0*degree);

if isempty(dxy)
  
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
    return
  end

  % second estimate of the grid resolution
  % works good for square grids that are not rotated
  xyEst = subSample(xy,10000);
  dxy2 = [mean(diff(uniquetol(xyEst(:,1),dxy(1)/100,'DataScale',1))),...
    mean(diff(uniquetol(xyEst(:,2),dxy(end)/100,'DataScale',1)))];

else

  dxy2 = dxy;

end

% check for square grid
% (use a tolerance instead of exact == since coordinates may be rotated
% or otherwise not bit-identical, and fall back gracefully instead of
% crashing when fewer than two points share the reference coordinate)
col = xy(abs(xy(:,1)-xy(2,1)) < dxy2(1)*1e-3, 2);
row = xy(abs(xy(:,2)-xy(2,2)) < dxy2(2)*1e-3, 1);
if numel(col) > 1 && numel(row) > 1 && ...
    abs(dxy2(1) - dxy2(2))/min(dxy2) <  1e-3 && ...
    abs((min(diff(uniquetol(col,'DataScale',1))) - dxy2(2))/dxy2(2)) < 0.01 && ...
    abs((min(diff(uniquetol(row,'DataScale',1))) - dxy2(1))/dxy2(1)) < 0.01
  unitCell = regularPoly(4,dxy2,0);
  return
end

% maybe it is a grid after all, just rotated - try to detect the lattice
% directly from nearest-neighbor statistics, which is much cheaper than
% a full Voronoi decomposition. Falls through to Voronoi below if the
% point set does not look like a clean lattice.
unitCell = detectLattice(xy);
if ~isempty(unitCell), return; end


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
    
  % third estimate of the grid resolution
  dxy2 = min(vecnorm(unitCell.',2));
catch
  unitCell = [];
end

dxy = dxy2;

%if 100*dxy3 > dxy2, dxy = dxy2; end
   
if ~isempty(unitCell) && isRegularPoly(unitCell,varargin)
  return
end

if isempty(cellType)
  if length(unitCell) == 6
    cellType = 'hexagonal';
  else
    cellType = 'rectangular';
  end
end

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

c = exp(1i*((pi/s:pi/(s/2):2*pi)+rot))./sqrt((s/2));
unitCell = [real(c(:)),imag(c(:))].*d;


function isRegular = isRegularPoly(unitCell,varargin)

sideLength = sqrt(sum((unitCell).^2,2));
sides      = numel(sideLength);

uC = complex(unitCell(:,1),unitCell(:,2));
nC = uC([2:end 1]);

enclosingAngle = uC./nC;
enclosingAngle = complex(abs(real(enclosingAngle)),...
  abs(imag(enclosingAngle)));

isRegular = any(sides == [4 6]) && ... % norm(sideLength - mean(sideLength))*dxy < 1e-5 && ...
  norm(enclosingAngle - mean(enclosingAngle)) < 0.05*degree;


% try to detect a (possibly rotated) square or hex point lattice from
% nearest-neighbor statistics. Returns [] if xy does not look like a
% clean lattice, in which case the caller should fall back to Voronoi.
function unitCell = detectLattice(xy)

unitCell = [];

% work on a spatially contiguous (not globally random!) chunk of points
% so the local neighbor structure of the lattice is preserved while the
% KD-tree stays cheap to build and query
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

% a translation vector v and its negation -v represent the same lattice
% direction; doubling the angle maps {theta, theta+pi} onto the same
% value on the full circle [0,2pi), which sidesteps having to special
% case the wrap at theta=0/pi (same trick MTEX uses for antipodal axes)
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
  % candidate square lattice: two directions ~90 deg apart, equal length
  dAng = mod(abs(diff(clustAng)),pi);
  dAng = min(dAng, pi-dAng);
  if abs(dAng - pi/2) < 0.08 && abs(diff(clustLen))/mean(clustLen) < 0.05 && lenSpread < 0.12
    unitCell = regularPoly(4,mean(clustLen),clustAng(1));
  end
elseif nClust == 3
  % candidate hex lattice: three directions 60 deg apart, equal length
  a = sort(clustAng);
  d1 = mod(a(2)-a(1),pi); d2 = mod(a(3)-a(2),pi); d3 = mod(a(1)-a(3)+pi,pi);
  if all(abs([d1 d2 d3] - pi/3) < 0.08) && ...
      (max(clustLen)-min(clustLen))/mean(clustLen) < 0.05 && lenSpread < 0.12
    unitCell = regularPoly(6,mean(clustLen),a(1));
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
