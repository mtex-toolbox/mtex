function par = paris(grains)
% returns the paris defined by Heilbronner & Keulen 2006
%
%% Input
%  grains - @grain
%
%% Output
%  par   - paris
%
%% See also
% grain/deltaarea grain/equivalentperimeter grain/equivalentradius
%


P = perimeter(grains);
PE = hullperimeter(grains);
par = 2*((P-PE)./PE)*100;
