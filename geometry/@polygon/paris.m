function par = paris( p )
% returns the paris defined by Heilbronner & Keulen 2006
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  par   - paris
%
%% See also
% polygon/deltaarea polygon/equivalentperimeter polygon/equivalentradius
%

p = polygon( p );

P = perimeter(p);
PE = hullperimeter(p);
par = 2*((P-PE)./PE)*100;
