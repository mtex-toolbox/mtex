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

if ~isa(v,'vector3d'), v = vector3d.byXYZ(v); end

rot = rotation.byAxisAngle(v,atan(norm(v))*2);
