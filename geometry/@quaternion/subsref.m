function q = subsref(q,s)
% overloads subsref

q.a = subsref(q.a,s);
q.b = subsref(q.b,s);
q.c = subsref(q.c,s);
q.d = subsref(q.d,s);
