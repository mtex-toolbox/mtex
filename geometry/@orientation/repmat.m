function rot = repmat(rot,varargin) 
% overloads repmat

rot.quaternion = repmat(rot.quaternion,varargin{:});
rot.i = repmat(rot.i,varargin{:});
