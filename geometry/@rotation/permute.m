function rot = permute(rot,varargin) 
% overloads permute

rot.quaternion = permute(rot.quaternion,varargin{:});
rot.i = permute(rot.i,varargin{:});
