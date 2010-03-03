function r = Euler(varargin)
% converts euler angle to rotation / orientation
%
%% Description
% The method *Euler* defines a [[rotation_index.html,rotation]]
% by Euler angles. You can choose whether to use the Bunge (phi,psi,phi2) 
% convention or the Matthies (alpha,beta,gamma) convention.
%
%% Syntax
%
%  q = Euler(alpha,beta,gamma)
%  q = Euler(phi1,Phi,phi2,'Bunge')
%
%% Input
%  alpha, beta, gamma - double
%  phi1, Phi, phi2    - double
%
%% Output
%  q - @quaternion
%
%% Options
%  ABG, ZYZ   - Matthies (alpha, beta, gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi1,Phi,phi2) convention 
%
%% See also
% euler2quat rotation/rotation orientation/orientation quaternion/Euler

r = rotation('Euler',varargin{:});

