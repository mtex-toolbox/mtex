function p = equivalentperimeter(p)
% returns the equivalent perimeter of grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  p   - perimeter
%
%% See also
% polygon/deltaarea polygon/paris polygon/equivalentradius

p = 2*pi*equivalentradius(p);