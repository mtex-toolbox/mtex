function r = equivalentradius(grains)
% returns the equivalent radius of grain-polygon
%
% defined as 
%
% $$ r = \sqrt{\frac{A}{\pi}} $$,
%
% where $A$ is the [[Grain2d.area.html,area]] of a grain
%
% Input
%  grains - @grain2d
%
% Output
%  r  - radius
%
% See also
% grain2d/deltaarea grain2d/equivalentperimeter grain2d/paris

r = sqrt(area(grains)/pi);
