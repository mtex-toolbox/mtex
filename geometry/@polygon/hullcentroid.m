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
% polygon/centroid polygon/principalcomponents

cVertices = centroid(convhull(p));
