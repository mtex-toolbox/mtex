function rot = byRodrigues(v,varargin)
% define rotations by Rodrigues vectors
%
% Syntax
%   rot = rotation.byRodrigues(v)
%
% Input
%  v - Rodrigues @vector3d
%
% Output
%  rot - @rotation
%
% See also
% rotation/rotentation rotation/byEuler rotation/byMatrix rotation/map

rot = rotation.byAxisAngle(v,atan(norm(v))*2);
