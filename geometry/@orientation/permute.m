function o = permute(o,varargin) 
% overloads permute

o.quaternion = permute(o.quaternion,varargin{:});
o.i = permute(o.i,varargin{:});
