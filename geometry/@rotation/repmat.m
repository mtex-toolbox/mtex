function q = repmat(q,varargin) 
% overloads repmat

q.a = repmat(q.a,varargin{:});
q.b = repmat(q.b,varargin{:});
q.c = repmat(q.c,varargin{:});
q.d = repmat(q.d,varargin{:});
q.i = repmat(q.i,varargin{:});
