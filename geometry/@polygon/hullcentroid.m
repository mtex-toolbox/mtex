function cVertices = hullcentroid(p)
% returns the centroid of convexhull
%
%% Input
%  grains - @grain
%
%% Output
%  cVertices   - location [x y]
%
%% See also
% grain/centroid grain/principalcomponents

cVertices = centroid(convhull(p));
