function v = rotate_outer(v,q,varargin)
% rotate vector3d by quaternion
%
% Syntax
%   v = rotate_outer(v,20*degree) % rotation about the z-axis
%   rot = rotation_outer.byEuler(10*degree,20*degree,30*degree)
%   v = rotate_outer(v,rot)
%
% Input
%  v - @S2Grid
%  q - @quaternion
%
% Output
%  r - q * v;
%

v = rotate_outer(vector3d(v), q, varargin{:});

end
