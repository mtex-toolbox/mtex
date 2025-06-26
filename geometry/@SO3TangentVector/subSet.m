function v = subSet(v,varargin)
v = subSet@vector3d(v,varargin{:});
v.rot = subSet(v.rot,varargin{:});
end