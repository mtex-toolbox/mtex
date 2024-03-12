function T = convhull(v)
% convex hull of a list of vector3d
%
% Syntax
%   T = convhul(v)
%
% Input
%  v - @vector3d
%
% Output
%  T - list of triangles
%

T = convhull(v.xyz);
