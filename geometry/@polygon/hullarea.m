function s = hullarea(p)
% returns the area of the convexhull of a polygon
%
%% Input
%  grains - @grain
%
%% Output
%  s   - size
%
%% See also
% grain/area grain/grainsize

[h s] = convhull(p);