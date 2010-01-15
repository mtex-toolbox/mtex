function o = reshape(o,varargin) 
% overloads reshape


o.quaternion = reshape(o.quaternion,varargin{:});
o.i = reshape(o.i,varargin{:});

