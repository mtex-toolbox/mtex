function v = plus(varargin)
% ensure that result is not S2Grid anymore

v = vector3d(plus@vector3d(varargin{:}));