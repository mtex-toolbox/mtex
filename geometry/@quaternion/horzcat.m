function q = horzcat(varargin)
% implements [q1,q2,q3..]

qs = repmat(struct(varargin{1}),size(varargin));
for k=1:numel(varargin)
  qs(k) = struct(varargin{k});
end

q = varargin{1};
q.a = horzcat(qs.a);
q.b = horzcat(qs.b);
q.c = horzcat(qs.c);
q.d = horzcat(qs.d);