function cxy = hullcentroid(grains)
% returns the centroid of convexhull
%
%% Input
%  grains - @grain
%
%% Output
%  cxy   - location [x y]
%
%% See also
% grain/centroid grain/principalcomponents

cxy = centroid(grains,'hull');
