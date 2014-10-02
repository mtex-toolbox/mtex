function ori = idRotation(varargin)
% the identical rotation

ori = rotation(idquaternion(varargin{:}));
