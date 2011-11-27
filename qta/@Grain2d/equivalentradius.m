function r = equivalentradius(grains)
% returns the equivalent radius of grain-polygon
%
%% Input
%  grains - @Grain2d
%
%% Output
%  r  - radius
%
%% See also
% Grain2d/deltaarea Grain2d/equivalentperimeter Grain2d/paris

r = sqrt(area(grains)/pi);
