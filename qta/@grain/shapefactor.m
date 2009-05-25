function F = shapefactor( grains )
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

P = perimeter(grains);
Pequ = equivalentperimeter(grains);

F = P./Pequ;




