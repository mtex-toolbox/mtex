function s = hullarea(grains)
% returns the area of the convexhull of a grain
%
%% Input
%  grains - @grain
%
%% Output
%  s   - size
%
%% See also
% grain/area grain/grainsize

s = grainsize(grains,'hull');