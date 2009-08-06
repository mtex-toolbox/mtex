function v = reshape(v,varargin) 
% overloads reshape

v.x = reshape(v.x,varargin{:});
v.y = reshape(v.y,varargin{:});
v.z = reshape(v.z,varargin{:});
