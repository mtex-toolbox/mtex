function m = mean(v,varargin)
% computes the mean vector 
%
%% Input
%  v - @vector3d
%
%% Output
%  m - @vector3d
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
% 

if check_option(varargin,'antipodal')
  M = [v.x(:) v.y(:) v.z(:)];
  M = M.' * M;
  s = svds(M,1);
  m = vector3d(s(1),s(2),s(3));
else
  m = sum(v);  
end

m = m ./ norm(m);
