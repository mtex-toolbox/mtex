function a = angle(v1,v2,varargin)
% angle between two vectors
%% Input
%  v1, v2 - @vector3d
%
%% Output
%  angle  - double
%
%% Options
%  axial  - include [[AxialDirectional.html,antipodal symmetry]]

if check_option(varargin,'axial')
  a = abs(dot(v1./norm(v1),v2./norm(v2)));
else
  a = dot(v1./norm(v1),v2./norm(v2));
end

a = acos(max(-1,min(1,a)));
