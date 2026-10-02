function [v, r]= refine(v)
% refine vectors
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d with half the resolution

v.resolution = v.resolution / 2;
  
v = v(:);

% the south pole closes the hull below a cap, and no triangle on it is wanted
tri = convhulln([v.xyz; 0 0 -1]);
tri(any(tri > length(v),2),:) = [];

r = sum(vector3d(v.subSet(tri)),2);
r = r./norm(r);

% a cap stays a cap
r(r.theta > max(v.theta(:)) + 1e-9) = [];

v = [v; r(:)];
