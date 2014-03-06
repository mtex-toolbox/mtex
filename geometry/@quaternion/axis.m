function v = axis(q)
% rotational axis of the quaternion
%% Syntax
%  v = axis(q)
%
%% Input
%  q - @quaternion
%
%% Output
%  v - @vector3d

v = vector3d(q.b,q.c,q.d);
v(q.a<0) = -v(q.a<0);
v(isnull(norm(v))) = xvector;
v = v./norm(v);
