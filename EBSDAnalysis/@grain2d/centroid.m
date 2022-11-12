function c = centroid(grains)
% barycenters of the grains
% 
% Syntax
%
%   c = grains.centroid
%
% Input
%  grains - @grain2d
%
% Output
%  c - @vector3d
%
% See also
% grain2d/fitEllipse
%

% extract vertices as vector3d -> grains.V should be vector3d!
if size(grains.V,2)==2
  V = vector3d(grains.V(:,1), grains.V(:,2),0);
else
  V = vector3d(grains.V(:,1), grains.V(:,2), grains.V(:,3));
end

% duplicate vertices according to their occurence in the grain2s
V = V([grains.poly{:}]);

% compute the relative area of the triangles between the edges an a
% potential center (here (0,0,0) - but the center does not matter here)
a = dot(cross(V(1:end-1),V(2:end)), grains.N);

% weight the vertices according to the area
aV = a .* (V(1:end-1)+V(2:end));

% average the weighte vertices for each polygon (grain)
cs = [0; cumsum(cellfun('prodofsize',grains.poly))];

c = vector3d.nan(length(grains),1);
for k=1:length(c)
  ndx = cs(k)+1:cs(k+1)-1;
  c(k)  = sum(aV(ndx)) / 3 / sum(a(ndx));
end

% some test code
% mtexdata fo
% plot(ebsd)
% grains = calcGrains(ebsd)
% plot(grains(1806))
% c = centroid(grains(1806));
% hold on, plot(c.x,c.y,c.z,'o','color','b'); hold off
