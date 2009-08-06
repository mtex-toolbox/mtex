function q = vertcat(varargin)
% implements [q1;q2;q3..]

qs = repmat(struct(varargin{1}),size(varargin));
for k=1:numel(varargin)
  qs(k) = struct(varargin{k});
end

q = varargin{1};
q.a = vertcat(qs.a);
q.b = vertcat(qs.b);
q.c = vertcat(qs.c);
q.d = vertcat(qs.d);
