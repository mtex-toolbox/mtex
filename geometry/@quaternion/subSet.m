function q = subSet(q,ind)
% indexing of quaternions
%
% Syntax
%   subSet(q,ind) % 
%

q.a = q.a(ind);
q.b = q.b(ind);
q.c = q.c(ind);
q.d = q.d(ind);

