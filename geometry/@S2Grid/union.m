function s = union(s1,s2)
% union of two S2Grids
%% Input
%  s1, s2 - @S2Grid
%% Output
%  "not indexed" - @S2Grid

s.res = min(s1.res,s2.res);
s.theta = [s1.theta,s2.theta];
s.rho = [s1.rho,s2.rho];
s.Grid = [reshape(s1.Grid,1,[]),reshape(s2.Grid,1,[])];
s.options = {};

if check_option(s1.options,'hemisphere') && ...
    check_option(s2.options,'hemisphere')
  s.options = {'hemisphere'};
end

s = class(s,'S2Grid');
