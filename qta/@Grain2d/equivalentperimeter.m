function p = equivalentperimeter(grains)
% returns the equivalent perimeter of grain-polygon
%
%% Input
%  grains - @Grain2d
%
%% Output
%  p   - perimeter
%
%% See also
% Grain2d/deltaarea Grain2d/paris Grain2d/equivalentradius

p = 2*pi*equivalentradius(grains);