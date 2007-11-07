function q = ctranspose(q1)
% transpose quaternion

q = quaternion(q1.a,-q1.b,-q1.c,-q1.d);
