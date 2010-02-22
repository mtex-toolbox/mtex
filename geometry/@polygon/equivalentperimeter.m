function p = equivalentperimeter(p)
% returns the equivalent perimeter of grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  p   - perimeter
%
%% See also
% grain/deltaarea grain/paris grain/equivalentradius

p = 2*pi*equivalentradius(p);