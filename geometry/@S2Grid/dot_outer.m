function d = dot_outer(S2G1,S2G2)
% outer innder product between two S2Grids
%
%% Input
%  S2G1, S2G2 - @S2Grid
%
%% Output
%  dist matrix - dimension: [numel(S2G1),numel(S2G2)]
%
%% Options
%  axial      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% See also
% S2Grid/find
%
d = dot_outer(reshape(vector3d(S2G1),[],1),...
  reshape(vector3d(S2G2),1,[]));

if (isa(S2G1,'S2Grid') && check_option(S2G1,'axial'))...
    || (isa(S2G2,'S2Grid') && check_option(S2G2,'axial'))
  d = abs(d);
end
