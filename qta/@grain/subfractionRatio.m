function r = subfractionRatio(grains)
% returns the a ratio between subractions an borderlength
%
%% Input
%  grains   - @grain
%
%% Output
% r - ratio
%

b = find(hasSubfraction(grains));
r = zeros(size(grains));
r(b) = subfractionLength(grains(b))./perimeter(grains(b));