function p = polytope(grains,varargin)
% returns the polygon of grains as struct
%
%% Input
%  grains - @grain
%
%% Output
%  p    - @polygon
%
% p = grains.polygon;

p = get(grains,'polytope');
if ispolygon(p)
  p = polygon(p);
elseif ispolyeder(p)
  p = polyeder(p);
end
