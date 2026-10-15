function v = cross(varargin)
% ensure that result is not S2Grid anymore

v = vector3d(cross@vector3d(varargin{:}));