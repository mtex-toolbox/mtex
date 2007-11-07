function q = uminus(q1)
% overload unitary minus
 
q = quaternion(-q1.a,-q1.b,-q1.c,-q1.d);
