function v = sparse(i,j,v,varargin)

v.x = sparse(i,j,v.x,varargin{:});
v.y = sparse(i,j,v.y,varargin{:});
v.z = sparse(i,j,v.z,varargin{:});