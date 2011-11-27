function F = shapefactor( grains )
% calculates the shapefactor of the grain-polygon, without Holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  F    - shapefactor
%
%% See also
% polygon/aspectratio polygon/equivalentperimeter polygon/perimeter


F = perimeter(grains)./equivalentperimeter(grains);

