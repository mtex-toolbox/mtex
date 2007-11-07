function b = eq(q1,q2)
% ? q1 == q2

b = isappr(q1.a,q2.a) & isappr(q1.b,q2.b) &...
	isappr(q1.c,q2.c) & isappr(q1.d,q2.d);
