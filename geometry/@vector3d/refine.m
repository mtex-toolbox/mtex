function [v r]= refine(v)
% refine vectors
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d with half the resolution

v.resolution = v.resolution / 2;
  
v = [v(:); -zvector];
d = squeeze(double(v));
  
tri = convhulln(d);
  
r = sum(vector3d(v(tri)),2);
r = r./norm(r);
  
[thetav] = polar(v);
[theta] = polar(r);
r(theta > max(thetav(:))) = [];

v = [v; r(:)];
