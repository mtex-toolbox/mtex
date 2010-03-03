function  peri = hullperimeter(p)
% returns the perimeter of grain polygon, without holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  peri   - perimeter
%
%% See also
% polygon/borderlength 
%

peri = perimeter(convhull(p));