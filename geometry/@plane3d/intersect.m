function v = intersect(plane,v1,v2)
% intersection of lines and planes
%
% Input
%  plane - @plane3d
%  v1 - starting points of the lines
%  v2 - final point of the lines
%  n  - normal direction of the planes
%  d  - distances of the plane, i.e. <x,n>=d 
%
% Output
%  v - intersection points @vector3d

% direction vector of the line
l = v2 - v1;

% compute intersection point
lambda = (plane.d - dot_outer(v1,plane.N,'noSymmetry')) ./ dot(l,plane.N,'noSymmetry');

% verify intersection point is between v1 and v2
lambda(lambda<-1e-13) = nan;
lambda(lambda>1+1e-13) = nan;

v = v1 + lambda .* l;