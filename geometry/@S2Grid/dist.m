function d = dist(S2G1,S2G2)
% distance matrix between two S2Grids
%% Input
%  S2G1, S2G2 - @S2Grid
%% Output
%  dist matrix - dimension: [numel(S2G1),numel(S2G2)]

d = dot_outer(reshape(vector3d(S2G1),[],1),...
  reshape(vector3d(S2G2),1,[]));

if (isa(S2G1,'S2Grid') && check_option(S2G1,'hemisphere'))...
    || (isa(S2G2,'S2Grid') && check_option(S2G2,'hemisphere'))
  d = abs(d);
end
