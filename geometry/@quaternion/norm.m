function n = norm(q)
% quaternion norm sqrt(a^2+b^2+c^2+c^2)

n = sqrt(q.a.^2+q.b.^2+q.c.^2+q.d.^2);
