function v = subSet(v,varargin)

v = subSet@vector3d(v,varargin{:});
v.oriRef = subSet(v.oriRef,varargin{:});

end