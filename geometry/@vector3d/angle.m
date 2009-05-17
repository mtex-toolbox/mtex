function a = angle(v1,v2,varargin)
% angle between two vectors
%% Input
%  v1, v2 - @vector3d
%% Output
%  angle - double

if check_option(varargin,'axial')
  a = acos(abs(dot(v1./norm(v1),v2./norm(v2))));
else
  a = acos(dot(v1./norm(v1),v2./norm(v2)));
end
