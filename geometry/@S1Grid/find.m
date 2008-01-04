function ind = find(S1G,x,epsilon)
% find close points
%
%% Syntax:  
% ind = find(S1G,x,epsilon) % find all points in distance epsilon
% ind = find(S1G,x)         % find closest point
%
%% Input
%  S1G     - @S1Grid
%  x       - double
%  epsilon . double
%
%% Output
%  ind - int32

d = dist(S1G,x);
if nargin == 3
  ind = find(d<epsilon);
else
  ind = find(d==min(d),1);
end
