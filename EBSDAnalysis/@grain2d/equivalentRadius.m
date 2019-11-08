function r = equivalentRadius(grains)
% returns the equivalent radius of grain-polygon
%
% defined as 
%
% $$ r = \sqrt{\frac{A}{\pi}} $$,
%
% where $A$ is the <grain2d.area.html area> of a grain
%
% Input
%  grains - @grain2d
%
% Output
%  r  - radius (in measurement units)
%
% See also
% grain2d/deltaarea grain2d/equivalentPerimeter grain2d/paris

r = sqrt(area(grains)/pi);
