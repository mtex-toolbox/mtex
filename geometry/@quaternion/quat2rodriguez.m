function v = quat2rodriguez(q)
% quaternion to rodriguez representation
%
%% Description
% calculates the Rodriguez vector for an rotation |q|
%
%% Input
%  q - @quaternion
%% Output
%  v - @vector3d
%% See also
% quaternion/quat2euler

v = vector3d(q.b./q.a,q.c./q.a,q.d./q.a);
