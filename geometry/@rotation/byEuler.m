function rot = byEuler(varargin)
% define rotentations by Euler angles
%
% Syntax
%   rot = rotation.byEuler(phi1,Phi,phi2)          % Bunge convention
%   rot = rotation.byEuler(alpha,beta,gamma,'ZYZ') % Matthies convention
%   rot = rotation.byEuler(phi1,Phi,phi2,'Kocks')  % Kocks convention
%
% Input
%  phi1, Phi, phi2 - Euler angles in radiant
%
% Output
%  rot - @rotation
%
% Flags
%  Bunge, ZXZ - 
%  ABG, Matthies, ZYZ - 
%  Roe - 
%  Kocks - 
%  Canova - 
%
% See also
% rotentation/rotentation rotentation/byMiller rotentation/byAxisAngle
% rotation/map


q = euler2quat(varargin{:});

rot = rotation(q);