function b = eq(q1,q2)
% ? q1 == q2

b = dot(q1,q2) > 1-1e-7;

