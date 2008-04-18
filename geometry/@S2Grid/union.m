function s = union(s1,varargin)
% union of two S2Grids
%
%% Syntax
% 
%  s = union(s1,s2,..,sN)
%
%% Input
%  s1, s2, sN - @S2Grid
%% Output
%  s      - @S2Grid
%

s = s1;

for i = 1:numel(varargin)
  
  s2 = varargin{i};
  if isa(s2,'S2Grid')  
    s.res = min(s.res,s2.res);
    s.theta = [s.theta,s2.theta];
    s.rho = [s.rho,s2.rho];
    s.Grid = [reshape(s.Grid,1,[]),reshape(s2.Grid,1,[])];
    s.options = {};
    if check_option(s.options,'hemisphere') && ...
        check_option(s2.options,'hemisphere')
      s.options = {'hemisphere'};
    end
  end
end
