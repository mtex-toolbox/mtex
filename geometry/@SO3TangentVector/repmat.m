function v = repmat(v,varargin)
%

v = repmat@vector3d(v,varargin{:});
v.oriRef = repmat(v.oriRef,varargin{:});

end