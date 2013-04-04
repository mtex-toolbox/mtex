function nq = mrdivide(q,d)
% scalar division

nq = quaternion(q.a/d,q.b/d,q.c/d,q.d/d);


