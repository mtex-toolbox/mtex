function v = repmat(v,varargin) 

v = repmat@vector3d(v,varargin{:});
v.rot = repmat(v.rot,varargin{:});

end