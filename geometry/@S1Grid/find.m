function ind = find(S1G,x,epsilon)
% find close points
%
% Syntax  
%   ind = find(S1G,x,epsilon) % find all points in distance epsilon
%   ind = find(S1G,x)         % find closest point
%
% Input
%  S1G     - @S1Grid
%  x       - double
%  epsilon - double
%
% Output
%  ind - int32

if S1G(1).periodic, p = S1G.max - S1G.min; else, p = 0; end

% the mex functions below read their input with mxGetPr, i.e. they require
% double and would silently misinterpret single precision input
if nargin == 2
  ind = S1Grid_find(double(S1G.points(:)),double(S1G.min),double(p),double(x));
else
  ind = S1Grid_find_region(double(S1G.points(:)),double(S1G.min),double(p),double(x),double(epsilon));
end
