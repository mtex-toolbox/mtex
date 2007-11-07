function q=transpose(q1)
% transpose array of quaternions

q = quaternion(q1.a.',q1.b.',q1.c.',q1.d.');
