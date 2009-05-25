function r = equivalentradius(grains)
% returns the equivalent radius of grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  r  - radius
%
%% See also
% grain/deltaarea grain/equivalentperimeter grain/paris

r = sqrt(area(grains)/pi);
