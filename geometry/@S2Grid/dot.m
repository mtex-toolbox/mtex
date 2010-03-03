function d = dot(S2G1,S2G2)
% inner product between two S2Grids
%
%% Input
%  S2G1, S2G2 - @S2Grid
%
%% Output
%  double - dimension: size(S2G1)
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% See also
% S2Grid/find
%
d = dot(vector3d(S2G1),vector3d(S2G2));
  
if (isa(S2G1,'S2Grid') && check_option(S2G1,'antipodal'))...
    || (isa(S2G2,'S2Grid') && check_option(S2G2,'antipodal'))
  d = abs(d);
end
