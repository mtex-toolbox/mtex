function q = cat(dim,varargin)
% 

q = varargin{1};

qa = cell(size(varargin)); qb = qa; qc = qa; qd = qa;
for i = 1:length(varargin)
  qs = varargin{i};
  qa{i} = qs.a;
  qb{i} = qs.b;
  qc{i} = qs.c;
  qd{i} = qs.d;
end

q.a = cat(dim,qa{:});
q.b = cat(dim,qb{:});
q.c = cat(dim,qc{:});
q.d = cat(dim,qd{:});
