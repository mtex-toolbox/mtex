function v = Rodrigues(q)
% quaternion to rodrigues representation
%
% Description
% calculates the Rodrigues vector for a quaternion |q|
%
% Input
%  q - @quaternion
%
% Output
%  v - @vector3d
%
% See also
% quaternion/Euler

q.a(q.a==0) = 1e-100;
v = vector3d(q.b./q.a,q.c./q.a,q.d./q.a);

% |v|^2 = sin[w/2]^2 / cos(w/2)^2
% w = 2*atan(|v|)
