function area = polyArea(v,varargin)
% area of a flat polygon given by vertices v1, v2, ..., v_n
%
% Input
%  v - @vector3d
%
% Output
%  area - area the polygon v1, v2, ..., v_n
%

nv = length(v);
if nv<3, area = 0; return; end

% formula from http://geomalgorithms.com/a01-_area.html
v1 = v.subSet(1);
N = normalize(mean(cross(v.subSet(2)-v1,v.subSet(3:nv-1)-v1)));

area = dot(N, sum(cross(v.subSet(1:nv-1),v.subSet(2:nv))))./2;
