function d = dot_outer(S2G1,S2G2)
% outer innder product between two S2Grids
%
%% Input
%  S2G1, S2G2 - @S2Grid
%
%% Output
%  dot matrix - dimension: [numel(S2G1),numel(S2G2)]
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% See also
% S2Grid/find
%
d = dot_outer(vector3d(S2G1),vector3d(S2G2));
  
if (isa(S2G1,'S2Grid') && check_option(S2G1,'antipodal'))...
    || (isa(S2G2,'S2Grid') && check_option(S2G2,'antipodal'))
  d = abs(d);
end
