function [NG,ind] = subGrid(S1G,x,epsilon)
% epsilon - neighborhood of a point in the grid
%% Syntax
%  [NG,ind] = subGrid(S1G,midpoint,radius)
%
%% Input
%  S1G        - @S1Grid
%  midpoint   - double
%  radius     - double
%% Output
%  NG         - @S1Grid
%  ind        - int32

if nargin == 3
  ind = find(S1G,x,epsilon);
else
  ind = x;
end

NG = S1Grid(reshape(S1G.points(ind),1,[]),S1G.min,S1G.max);
NG.periodic = S1G.periodic;
