function [cha, chp] = convexhullProps(grains)
% Area of the convex hull of grains 
% Note: this is only reasonable for smooth and sufficiently large grains
% 
%
% Syntax
%   [cha, chp] = convexhullArea(grains)
%
% Input
%  grains - @grain2d
%
% Output
%  cha - area of convex hull
%  chp - perimeter of convex hull
%
%

cha = zeros(size(grains));
chp = cha;

% store this in local variables for speed reasons
V = grains.rot2Plane .* grains.V;
X = V.x;
Y = V.y;

poly = grains.poly;
% remove inclusions
incl = grains.inclusionId;
for i = find(incl>0).'
  poly{i} = poly{i}(1:end-incl(i));
end

% compute convex hull perimeters
for id = 1:length(grains)
  
  % extract coordinates
  xGrain = X(poly{id});
  yGrain = Y(poly{id});
  
  % compute convex hull
  ixy = convhull(xGrain,yGrain);
  
  % area
  cha(id) = polySgnArea(xGrain(ixy),yGrain(ixy));
  
  % perimeter
  chp(id) = sum(sqrt(...
    (xGrain(ixy(1:end-1)) - xGrain(ixy(2:end))).^2 + ...
    (yGrain(ixy(1:end-1)) - yGrain(ixy(2:end))).^2));

end

