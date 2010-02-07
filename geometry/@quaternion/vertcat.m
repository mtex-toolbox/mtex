function q = vertcat(varargin)
% implements [q1;q2;q3..]

q = varargin{1};

for i = 1:numel(varargin)
  qs(i).a = varargin{i}.a;
  qs(i).b = varargin{i}.b;
  qs(i).c = varargin{i}.c;
  qs(i).d = varargin{i}.d;
end

q.a = vertcat(qs.a);
q.b = vertcat(qs.b);
q.c = vertcat(qs.c);
q.d = vertcat(qs.d);


