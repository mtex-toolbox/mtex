function q = horzcat(varargin)
% implements [q1,q2,q3..]

q = varargin{1};
qs = cat(2,varargin{:});
q.a = horzcat(qs.a);
q.b = horzcat(qs.b);
q.c = horzcat(qs.c);
q.d = horzcat(qs.d);