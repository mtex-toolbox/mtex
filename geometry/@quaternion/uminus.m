function q = uminus(q)
% overload unitary minus
 
q.a = -q.a;
q.b = -q.b;
q.c = -q.c;
q.d = -q.d;
