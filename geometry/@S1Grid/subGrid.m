function [NG,ind] = subGrid(S1G,x,epsilon)
% epsilon - neighborhood of a point in the grid
% usage:  [NG,ind] = subGrid(S1G,midpoint,radius)
%
%% Input
%  S1G        - @S1Grid
%  midpoint   - double
%  radius     - double
%% Output
%  NG         - @S1Grid
%  ind        - int32

ind = find(S1G,x,epsilon);
NG = S1Grid(S1G.points(ind),S1G.min,S1G.max);
NG.periodic = S1G.periodic;
