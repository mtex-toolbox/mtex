function quat = reshape(q,varargin) 
% overloads reshape

if isa(q,'quaternion')
	quat = quaternion(reshape(q.a,varargin{:}),reshape(q.b,varargin{:}),...
		reshape(q.c,varargin{:}),reshape(q.d,varargin{:}));
end
