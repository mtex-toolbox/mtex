function r = equivalentradius(p)
% returns the equivalent radius of grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  r  - radius
%
%% See also
% polygon/deltaarea polygon/equivalentperimeter polygon/paris

r = sqrt(area(p)/pi);
