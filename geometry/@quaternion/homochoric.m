function v = homochoric(q)
% homochoric coordinates of a quaternion 
%
% The 3-d homochoric coordinates of a quaternion results from the equal area
% lambert transformation of the 4-d quaternion coordinates on the unit
% sphere onto the ball.
%
% Input
%  q - @quaternion
%
% Output
%  v - @vector3d
%
% See also
% quaternion/Euler quaternion/Rodigues

% the direction
v = vector3d(q.b,q.c,q.d);

% scaling
omega = 2 * real(acos(abs(q.a)));
f = sign(q.a) ./ norm(v);
f(abs(omega) < 1e-10) = 0;
f = f .* (0.75 * ( omega - sin(omega) )).^(1/3) ;

% combining the result
v = f .* v;

% shortcut 
% omega = q.angle;
% v = q.axis .* (3./4 * (omega - sin(omega))).^(1/3);