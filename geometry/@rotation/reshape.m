function rot = reshape(rot,varargin) 
% overloads reshape


rot.quaternion = reshape(rot.quaternion,varargin{:});
rot.i = reshape(rot.i,varargin{:});

