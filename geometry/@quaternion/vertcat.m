function q = vertcat(varargin)
% implements [q1;q2;q3..]

q = quaternion;
qs = cat(1,varargin{:});
q.a = vertcat(qs.a);
q.b = vertcat(qs.b);
q.c = vertcat(qs.c);
q.d = vertcat(qs.d);
