function vr = reshape(v,varargin) 
% overloads reshape

if isa(v,'vector3d')
	vr = vector3d(reshape(v.x,varargin{:}),...
		reshape(v.y,varargin{:}),reshape(v.z,varargin{:}));
end
