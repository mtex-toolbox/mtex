function v = rotate(v,q,varargin)
% rotate vector3d by quaternion
%
% Syntax
%   v = rotate(v,20*degree) % rotation about the z-axis
%   rot = rotation.byEuler(10*degree,20*degree,30*degree)
%   v = rotate(v,rot)
%
% Input
%  v - @S2Grid
%  q - @quaternion
%
% Output
%  v - @vector3d
%

v = rotate(vector3d(v), q, varargin{:});

end
