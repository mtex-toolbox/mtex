function p = paris(grains)
% Percentile Average Relative Indented Surface
%
% the paris (Percentile Average Relative Indented Surface) is shape
% parameter that measures the convexity of a grain
%
% Syntax
%   p = paris(grains)
%
% Input
%  grains - @grain2d
%
% Output
%  p - double
%
% 

hgrains = hull(grains);
hullp = hgrains.perimeter;
p = 200 * (grains.perimeter - hullp)./hullp;

% sanity check - maybe some grains are too small,
% not sufficiently smoothed etc...
p(p==inf)=NaN; p(p<0)=NaN;

end

