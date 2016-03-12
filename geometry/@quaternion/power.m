function q = power(q,n)
% q.^n
%
% Syntax
%
% q = q^(-1)
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

nq = expquat(n .* log(q));

q.a = nq.a;
q.b = nq.b;
q.c = nq.c;
q.d = nq.d;
