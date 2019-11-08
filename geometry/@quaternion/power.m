function q = power(q,n)
% q.^n
%
% Syntax
%   q = q.^n
%
% q = q.^(-1)
% q = q.^2
% q = q.^[0,1,2,3]
%
%
% Input
%  q - @quaternion
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
omega = 2*acos(q.a);

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
