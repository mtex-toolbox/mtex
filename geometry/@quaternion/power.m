function q = power(q,n)
% q.^n
%
% For a unit quaternion q the power q.^n is the rotation about the same axis
% by n times the rotation angle; n may be any real number and an array.
%
% Syntax
%
%   q = q.^n            % the power n
%   q = q.^(-1)         % the inverse
%   q = q.^2            % twice the rotation
%   q = q.^[0,1,2,3]    % several powers at once
%
% Input
%  q - @quaternion
%  n - double
%
% Output
%  q - @quaternion 
%
% See also
% quaternion/ctranspose

% ensure q.a is non negative
s = 1-2*(q.a<0);
q.a = q.a*s;
q.b = q.b*s;
q.c = q.c*s;
q.d = q.d*s;
omega = 2*atan2(sqrt(q.b.^2 + q.c.^2 + q.d.^2),q.a);

q.a = cos(n*omega/2);

fak = sin(n*omega/2) ./ sin(omega/2);
fak(~isfinite(fak)) = 1;

q.b = q.b .* fak;
q.c = q.c .* fak;
q.d = q.d .* fak;

% old slow algorithm
%nq = expquat(n .* log(q));

%q.a = nq.a;
%q.b = nq.b;
%q.c = nq.c;
%q.d = nq.d;
