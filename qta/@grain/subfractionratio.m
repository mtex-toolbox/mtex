function r = subfractionratio(grains)
% returns the a ratio between subractions an borderlength
%
%% Input
%  grains   - @grain
%
%% Output
% r - ratio
%

b = find(hassubfraction(grains));
r = zeros(size(grains));
r(b) = subfractionlength(grains(b))./perimeter(grains(b));