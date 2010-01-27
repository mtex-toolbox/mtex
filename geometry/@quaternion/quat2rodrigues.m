function v = quat2rodrigues(q)
% quaternion to rodrigues representation
%
%% Description
% calculates the Rodrigues vector for an rotation |q|
%
%% Input
%  q - @quaternion
%% Output
%  v - @vector3d
%% See also
% quaternion/Euler

q.a(q.a==0) = 1e-100;
v = vector3d(q.b./q.a,q.c./q.a,q.d./q.a);
