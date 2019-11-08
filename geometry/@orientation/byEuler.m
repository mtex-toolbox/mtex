function ori = byEuler(varargin)
% define orientations by Euler angles
%
% Syntax
%   ori = orientation.byEuler(phi1,Phi,phi2,CS,SS) % Bunge convention
%   ori = orientation.byEuler(alpha,beta,gamma,'ZYZ',CS,SS) % Matthies convention
%   ori = orientation.byEuler(phi1,Phi,phi2,'Kocks',CS,SS) % Kocks convention
%
% Input
%  phi1, Phi, phi2 - Euler angles in radiant
%  CS - @crystalSymmetry
%  SS - @specimenSymmetry
%
% Output
%  ori - @orientation
%
% Flags
%  Bunge, ZXZ -
%  ABG, Matthies, ZYZ -
%  Roe -
%  Kocks - 
%  Canova -
%
% See also
% orientation/orientation orientation/byMiller orientation/byAxisAngle
% orientation/map

q = euler2quat(varargin{:});

ori = orientation(q,varargin{:});