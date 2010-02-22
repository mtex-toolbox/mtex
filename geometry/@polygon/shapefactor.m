function F = shapefactor( p )
% calculates the shapefactor of the grain-polygon, without holes
%
%% Input
%  grains - @grain
%
%% Output
%  F    - shapefactor
%
%% See also
% grain/aspectratio grain/equivalentperimeter grain/perimeter

p = polygon( p );

P = perimeter(p);
Pequ = equivalentperimeter(p);

F = P./Pequ;

