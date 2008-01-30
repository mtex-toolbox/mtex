function a = angle(v1,v2)
% angle between two vectors
%% Input
%  v1, v2 - @vector3d
%% Output
%  angle - double

a = acos(dot(v1./norm(v1),v2./norm(v2)));
