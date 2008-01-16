function d = dist(S2G1,S2G2)
% distance matrix between two S2Grids
%
%% Input
%  S2G1, S2G2 - @S2Grid
%
%% Output
%  dist matrix - dimension: [numel(S2G1),numel(S2G2)]
%
%% See also
% S2Grid/dot_outer S2Grid/find
%

d = acos(dot_outer(S2G1,S2G2));
