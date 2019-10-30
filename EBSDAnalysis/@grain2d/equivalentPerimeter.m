function p = equivalentPerimeter(grains)
% returns the equivalent perimeter of grain-polygon
%
% Description
% The equivalent perimeter of grain-polygon is defined as
%
% $$ p = 2 \pi ER $$,
%
% where $ER$ is the <grain2d.equivalentRadius.html equivalent radius> of a
% grain
%
% Input
%  grains - @grain2d
%
% Output
%  p - equivalent perimeter in measurement units
%
% See also
% grain2d/deltaarea grain2d/paris grain2d/equivalentRadius

p = 2*pi*equivalentRadius(grains);
