function s = hullarea(p)
% returns the area of the convexhull of a polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  s   - size
%
%% See also
% polygon/area grain/grainsize

[h s] = convhull(p);