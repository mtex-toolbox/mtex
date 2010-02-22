function par = paris( p )
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

p = polygon( p );

P = perimeter(p);
PE = hullperimeter(p);
par = 2*((P-PE)./PE)*100;
