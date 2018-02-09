function q = permute(q,varargin) 
% overloads permute

q.a = permute(q.a,varargin{:});
q.b = permute(q.b,varargin{:});
q.c =  permute(q.c,varargin{:});
q.d = permute(q.d,varargin{:});
q.i = permute(q.i,varargin{:});