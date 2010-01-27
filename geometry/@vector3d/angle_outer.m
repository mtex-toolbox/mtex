function a = angle_outer(v1,v2,varargin)
% angle between two vectors
%% Input
%  v1, v2 - @vector3d
%
%% Output
%  angle  - double
%
%% Options
%  antipodal  - include [[AxialDirectional.html,antipodal symmetry]]

if check_option(varargin,'antipodal')
  a = abs(dot_outer(v1./norm(v1),v2./norm(v2)));
else
  a = dot_outer(v1./norm(v1),v2./norm(v2));
end

a = acos(max(-1,min(1,a)));
