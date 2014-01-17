function v = repmat(v,varargin) 
% overloads repmat

v.x = repmat(v.x,varargin{:});
v.y = repmat(v.y,varargin{:});
v.z = repmat(v.z,varargin{:});
