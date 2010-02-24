function  peri = hullperimeter(p)
% returns the perimeter of grain polygon, without holes
%
%% Input
%  grains - @grain
%
%% Output
%  peri   - perimeter
%
%% See also
% grain/borderlength 
%

peri = perimeter(convhull(p));