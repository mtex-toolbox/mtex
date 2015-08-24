function isInside = checkInside( grains, xy )
% check for points or grains to be inside a big grain
%
% Syntax
%   isInside = checkInside(hostGrains, [x,y])
%   isInside = checkInside(hostGrains, inclusionGrains)
%
% Input
%  hostGrains      - @grain2d
%  inclusionGrains - @grain2d
%  [x,y] - list of [x(:) y(:)] coordinates
%
% Output
%  isInside - numInclusionGrains x numHostGrains matrix
%
% Example
%  mtexdata small
%  grains = calcGrains(ebsd('indexed'))
%  plot(grains(grains(75).checkInside(grains)))
%
% See also
% EBSD/findByLocation grain2d/findByOrientation


if isa(xy,'grain2d') 
  
  ind = ismember(xy.id,grains.id);
  
  % replace grains by its center
  xy = xy.centroid;
  
  % a grain should not contain itself
  xy(ind,:) = NaN;
end

isInside = false(size(xy,1),length(grains));

poly = grains.poly;
V = grains.V;

for i = 1:length(poly)

  p = poly{i};
  
  firstloop = find(p(2:end)==p(1),1);
  
  p = p(1:firstloop);
  Vx = V(p,1); Vy = V(p,2);
  
  isInside(:,i) = inpolygon(xy(:,1),xy(:,2),Vx,Vy);
  
end
