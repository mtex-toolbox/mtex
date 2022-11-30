function ori = byRodrigues(v,varargin)
% define orientations by Euler angles
%
% Syntax
%   ori = orientation.byRodrigues(v,CS,SS) % Bunge convention
%
% Input
%  v - @vector3d
%  CS - @crystalSymmetry
%  SS - @specimenSymmetry
%
% Output
%  ori - @orientation
%
% See also
% orientation/orientation orientation/byMiller orientation/byAxisAngle
% orientation/map

if ~isa(v,'vector3d'), v = vector3d(v); end

ori = orientation.byAxisAngle(v,atan(norm(v))*2,varargin{:});
