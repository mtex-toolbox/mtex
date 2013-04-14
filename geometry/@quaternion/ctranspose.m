function q = ctranspose(q)
% transpose quaternion

q.a =  q.a;
q.b = -q.b;
q.c = -q.c;
q.d = -q.d;
