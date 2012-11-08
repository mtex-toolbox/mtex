function q = sum(q,varargin)
% overloads sum

q.a = sum(q.a,varargin{:});
q.b = sum(q.b,varargin{:});
q.c = sum(q.c,varargin{:});
q.d = sum(q.d,varargin{:});
