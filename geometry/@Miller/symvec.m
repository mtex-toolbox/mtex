function v = symvec(m,varargin)
% directions symmetrically equivalent to m
%% Syntax
%  v = symeq(m)    - vectors symmetrically equivalent to m
%
%% Input
%  m - @Miller
%
%% Output
%  v - @vector3d
%
%% Options
%  axial - include [[AxialDirectional.html,antipodal symmetry]]

if length(m)~=1, error('Function supports only single vectors!');end

v = reshape(vector3d(m),1,[]);

if check_option(varargin,'axial')
  v = quaternion(m.CS) * v;
  v = [v;-v];
  if check_option(varargin,'plot'), v(getz(v)<-1e-6) = [];end
  v = cunion(v);%,@(a,b) norm(a-b).*(norm(a+b)+isnull(getz(b))));
else
  v = cunion(quaternion(m.CS) * v);
end
