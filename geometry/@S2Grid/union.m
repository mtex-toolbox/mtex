function s = union(s,varargin)
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

warning('This function seems not to work correctly!');
for i = 1:numel(varargin)
  
  s2 = varargin{i};
  if isa(s2,'S2Grid')  
    s.res = min(s.res,s2.res);
    s.theta = [s.theta,s2.theta];
    s.rho = [s.rho,s2.rho];
    s.vector3d = [reshape(s.vector3d,1,[]),reshape(s2.vector3d,1,[])];
    s.options = {s.options{:},s2.options{:}};
  end
end
