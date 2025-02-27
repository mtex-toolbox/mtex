function q = setSubSet(q,ind,nq)
% indexing of quaternions
%
% Syntax
%
%   % q(ind) = nq
%   q = setSubSet(q,ind,nq) 
%
% Input
%  q - @quaternion
%  ind - double
%  nq  - @quaternion
%
% Output
%  q - @quaternion
%

q.a(ind) = nq.a;
q.b(ind) = nq.b;
q.c(ind) = nq.c;
q.d(ind) = nq.d;

