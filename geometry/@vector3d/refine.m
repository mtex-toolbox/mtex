function [v, r]= refine(v)
% refine vectors
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d with half the resolution

v.resolution = v.resolution / 2;
  
v = [v(:); -zvector];
  
tri = convhulln(v.xyz);
  
r = sum(vector3d(v.subSet(tri)),2);
r = r./norm(r);
  
r(t.theta > max(v.theta(:))) = [];

v = [v; r(:)];
