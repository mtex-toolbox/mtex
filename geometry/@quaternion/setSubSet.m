function q = setSubSet(q,ind,nq)
% indexing of quaternions
%
% Syntax
%   setSubSet(q,ind) % 
%

q.a(ind) = nq.a;
q.b(ind) = nq.b;
q.c(ind) = nq.c;
q.d(ind) = nq.d;

