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

v = v./norm(v);
if check_option(varargin,'antipodal') || v.antipodal
  M = [v.x(:) v.y(:) v.z(:)];
  M = M.' * M;
  [u,s,v] = svds(M,1); %#ok<NASGU>
  m = vector3d(u(1),u(2),u(3));
else
  m = sum(v);  
end

m = m ./ norm(m);
