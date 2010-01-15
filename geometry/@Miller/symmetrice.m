function m = symmetrice(m,varargin)
% directions symmetrically equivalent to m
%
%% Syntax
%  v = symmetrice(m) - vectors symmetrically equivalent to m
%
%% Input
%  m - @Miller
%
%% Output
%  v - @vector3d
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]

%if length(m)~=1, error('Function supports only single vectors!');end

m.vector3d = (quaternion(m.CS) * reshape(m.vector3d,1,[])).';

if check_option(varargin,'antipodal')
  m.vector3d = [m.vector3d,-m.vector3d];
  if check_option(varargin,'plot'), m.vector3d(getz(m.vector3d)<-1e-6) = [];end
end

if size(m.vector3d,1) == 1
  m.vector3d = cunion(m.vector3d);
end
