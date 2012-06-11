function r = subBoundaryRatio(grains)
% returns the a ratio between sub grain an borderlength
%
%% Input
%  grains   - @grain
%
%% Output
% r - ratio
%

b = find(hasSubBoundary(grains));
r = zeros(size(grains));
r(b) = subBoundaryLength(grains(b))./perimeter(grains(b));