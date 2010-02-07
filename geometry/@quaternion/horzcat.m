function q = horzcat(varargin)
% implements [q1,q2,q3..]

q = varargin{1};

for i = 1:numel(varargin)
  qs(i).a = varargin{i}.a;
  qs(i).b = varargin{i}.b;
  qs(i).c = varargin{i}.c;
  qs(i).d = varargin{i}.d;
end

q.a = horzcat(qs.a);
q.b = horzcat(qs.b);
q.c = horzcat(qs.c);
q.d = horzcat(qs.d);


