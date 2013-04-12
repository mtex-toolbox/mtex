function q = vertcat(varargin)
% implements [q1;q2;q3..]

q = varargin{1};

qa = cell(size(varargin)); qb = qa; qc = qa; qd = qa;
for i = 1:numel(varargin)
  qs = varargin{i};
  qa{i} = qs.a;
  qb{i} = qs.b;
  qc{i} = qs.c;
  qd{i} = qs.d;
end

q.a = vertcat(qa{:});
q.b = vertcat(qb{:});
q.c = vertcat(qc{:});
q.d = vertcat(qd{:});

