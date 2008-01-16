function v = rotaxis(q)
% rotational axis of the quaternion
%% Syntax
%  v = rotaxis(q)
%
%% Input
%  q - @quaternion
%
%% Output
%  v - @vector3d

v = vector3d(q.b,q.c,q.d);
v(isnull(norm(v))) = xvector;
v = v./norm(v);
