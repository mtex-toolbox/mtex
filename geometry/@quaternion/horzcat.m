function q = horzcat(varargin)
% implements [q1,q2,q3..]

q = varargin{1};

if length(varargin) > 1
  q.a = cellfun(@(q) q.a,varargin);
  q.b = cellfun(@(q) q.b,varargin);
  q.c = cellfun(@(q) q.c,varargin);
  q.d = cellfun(@(q) q.d,varargin);
end
