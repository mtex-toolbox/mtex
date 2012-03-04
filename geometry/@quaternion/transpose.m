function q=transpose(q)
% transpose array of quaternions

q.a = q.a.';
q.b = q.b.';
q.c = q.c.';
q.d = q.d.';
