function v = reshape(v,varargin)

v = reshape@vector3d(v,varargin{:});
v.rot = reshape(v.rot,varargin{:});

end