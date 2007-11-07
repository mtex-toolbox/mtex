function quat = repmat(q,varargin) 
% overloads repmat

if isa(q,'quaternion')
	quat = quaternion(repmat(q.a,varargin{:}),repmat(q.b,varargin{:}),...
		repmat(q.c,varargin{:}),repmat(q.d,varargin{:}));
else
    error('this is for quaternions only')
end 
