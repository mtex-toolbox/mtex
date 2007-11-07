function vec = repmat(v,varargin) 
% overloads repmat

if isa(v,'vector3d')
	vec = vector3d(repmat(v.x,varargin{:}),...
		repmat(v.y,varargin{:}),repmat(v.z,varargin{:}));
else
    error('this is for vector3d only')
end 
