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


v = reshape(vector3d(m),1,[]);

if check_option(varargin,'reduced')
  v = cunion(quaternion(m.CS) * v,@(a,b) norm(a-b).*(norm(a+b)+isnull(getz(b))));
else
  v = cunion(quaternion(m.CS) * v);
end

