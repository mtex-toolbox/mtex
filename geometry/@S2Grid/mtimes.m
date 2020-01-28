function v = mtimes(varargin)
% ensure that result is not S2Grid anymore

v = vector3d(mtimes@vector3d(varargin{:}));