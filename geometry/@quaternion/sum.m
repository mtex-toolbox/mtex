function s = sum(q,varargin)
% overloads sum

s = quaternion(sum(q.a,varargin{:}),sum(q.b,varargin{:}),...
	sum(q.c),sum(q.d,varargin{:}));
