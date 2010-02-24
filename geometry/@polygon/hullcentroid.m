function cxy = hullcentroid(p)
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

cxy = centroid(convhull(p));
