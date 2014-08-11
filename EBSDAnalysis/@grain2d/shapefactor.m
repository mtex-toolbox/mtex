function F = shapefactor( grains )
% calculates the shapefactor of the grain-polygon, without Holes
%
% define as
%
% $$ F = \frac{P}{EP} $$,
%
% where $P$ is the [[Grain2d.perimeter.html,perimeter]] and  $EP$ is the
% [[Grain2d.equivalentperimeter.html,equivalent perimeter]].
%
% Input
%  p - @grain2d
%
% Output
%  F    - shapefactor
%
% See also
% polygon/aspectratio polygon/equivalentperimeter polygon/perimeter


F = perimeter(grains)./equivalentperimeter(grains);

