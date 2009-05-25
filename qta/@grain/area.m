function s = area(grains)
% calculates the area of the grain-polygon, with holes
%
%% Input
%  grains - @grain
%
%% Output
%  s    - area
%
%% See also
% grain/grainsize grain/hullarea

s = grainsize(grains,'area');