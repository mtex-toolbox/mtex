function q = reshape(q,varargin) 
% overloads reshape

q.a = reshape(q.a,varargin{:});
q.b = reshape(q.b,varargin{:});
q.c =  reshape(q.c,varargin{:});
q.d = reshape(q.d,varargin{:});
q.i = reshape(q.i,varargin{:});