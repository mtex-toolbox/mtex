function v = reshape(v,varargin)
%

v = reshape@vector3d(v,varargin{:});
v.oriRef = reshape(v.oriRef,varargin{:});

end