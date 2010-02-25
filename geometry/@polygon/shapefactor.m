function F = shapefactor( p )
% calculates the shapefactor of the grain-polygon, without holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  F    - shapefactor
%
%% See also
% polygon/aspectratio polygon/equivalentperimeter polygon/perimeter

p = polygon( p );

P = perimeter(p);
Pequ = equivalentperimeter(p);

F = P./Pequ;

