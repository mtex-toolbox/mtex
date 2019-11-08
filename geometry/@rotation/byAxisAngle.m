function rot = byAxisAngle(v,omega,varargin)
% define rotations by rotational axis and rotational angle
%
% Syntax
%   rot = rotation.byAxisAngle(v,omega)
%
% Input
%  v - rotational axis @vector3d
%  omega - rotation angle
%
% Output
%  rot - @rotation
%
% See also
% rotation/rotation rotation/byEuler rotation/byMatrix rotation/map

rot = rotation(axis2quat(v,omega));
