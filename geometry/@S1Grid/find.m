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

if S1G(1).periodic, p = S1G.max - S1G.min; else p = 0; end

if nargin == 2
  ind = S1Grid_find(S1G.points(:),S1G.min,p,x);
else  
  ind = S1Grid_find_region(S1G.points(:),S1G.min,p,x,epsilon);
end
