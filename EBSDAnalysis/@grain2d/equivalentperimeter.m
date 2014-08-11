function p = equivalentperimeter(grains)
% returns the equivalent perimeter of grain-polygon
%
% defined as
%
% $$ p = 2 \pi ER $$,
%
% where $ER$ is the [[Grain2d.equivalentradius.html,equivalent radius]] of
% a grain
%
% Input
%  grains - @grain2d
%
% Output
%  p   - perimeter
%
% See also
% grain2d/deltaarea grain2d/paris grain2d/equivalentradius

p = 2*pi*equivalentradius(grains);
