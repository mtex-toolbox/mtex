function v = project(plane,v)
% project points on planes
%
% Input
%  plane - @plane3d
%  v     - @vector3d
%
% Output
%  v - @vector3d

v = v - dot(v,plane.N) .* plane.N;