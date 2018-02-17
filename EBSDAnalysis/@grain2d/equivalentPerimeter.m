function p = equivalentPerimeter(grains)
% returns the equivalent perimeter of grain-polygon
%
% defined as
%
% $$ p = 2 \pi ER $$,
%
% where $ER$ is the [[Grain2d.equivalentRadius.html,equivalent radius]] of
% a grain
%
% Input
%  grains - @grain2d
%
% Output (in measurement units)
%
% See also
% grain2d/deltaarea grain2d/paris grain2d/equivalentRadius

p = 2*pi*equivalentRadius(grains);
