function isInside = checkInside(grains, xy, varargin)
% check for points or grains to be inside a big grain
%
% Syntax
%   isInside = checkInside(hostGrains, [x,y])
%   isInside = checkInside(hostGrains, inclusionGrains)
%   isInside = checkInside(hostGrains, ebsd)
%
% Input
%  hostGrains      - @grain2d
%  inclusionGrains - @grain2d
%  [x,y] - list of [x(:) y(:)] coordinates
%
% Output
%  isInside - numInclusionGrains x numHostGrains matrix
%
% Options
%
% Example
%  mtexdata small
%  grains = calcGrains(ebsd('indexed'))
%  plot(grains(grains(75).checkInside(grains)))
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

ignoreInklusions = check_option(varargin,'ignoreInklusions');

if isa(xy,'grain2d') 
  
  ind = ismember(xy.id,grains.id);
  
  % replace grains by its center
  xy = xy.centroid;
  
  % a grain should not contain itself
  xy(ind,:) = NaN;
  
  ignoreInklusions = true;
  
elseif isa(xy,'EBSD')
  
  % extract unit cell
  uc = xy.unitCell;
  
  % for EBSD data the complete unitcell should be contained
  xy = [xy.prop.x(:),xy.prop.y(:)];
  
  isInside = grains.checkInside(xy+repmat(uc(1,:),size(xy,1),1));
  for i = 2:size(uc,1)
    isInside = isInside & grains.checkInside(xy+repmat(uc(i,:),size(xy,1),1));
  end
  isInside = any(isInside,2);
  return
  
end

isInside = false(size(xy,1),length(grains));

poly = grains.poly;
V = grains.V;

for i = 1:length(poly)

  p = poly{i};
  
  if ignoreInklusions
    firstloop = find(p(2:end)==p(1),1);
    p = p(1:firstloop);
  end
  
  Vx = V(p,1); Vy = V(p,2);
  
  isInside(:,i) = inpolygon(xy(:,1),xy(:,2),Vx,Vy);
  
end
