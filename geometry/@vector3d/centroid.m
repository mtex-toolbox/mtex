function c = centroid(v,varargin)
% compute the centroid of a 2d polygon in 3d
%
% Syntax
%   c = centroid(v)   
%
% Input
%  v - @vector3d
%
% Output
%  c - @vector3d
%

% shift to origin
s = v.subSet(1);
v = v - s;

% rotate to xy plane
r = rotation.map(perp(v),zvector);
v = r * v;

% computed 2d centroid
x = [v.x(:);v.x(1)];
y = [v.y(:);v.y(1)];
A = x(1:end-1) .* y(2:end) - x(2:end) .* y(1:end-1);

c = vector3d(sum(A .* (x(1:end-1) + x(2:end))),...
  sum(A .* (y(1:end-1) + y(2:end))),0) ./ sum(A) ./ 3;

% rotate and shift back
c = s + inv(r)*c;
