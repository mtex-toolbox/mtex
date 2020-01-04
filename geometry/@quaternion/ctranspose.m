function q = ctranspose(q)
% transpose quaternion

q.b = -q.b;
q.c = -q.c;
q.d = -q.d;
