function o = repmat(o,varargin) 
% overloads repmat

o.quaternion = repmat(o.quaternion,varargin{:});
o.i = repmat(o.i,varargin{:});
