function [GV,GR,GVRH] = VRHShearModulus(S)
% Voigt-Reuss-Hill elastic shear moduli
%
% Syntax
%
%   [GV,GR,GVRH] = VRHShearModulus(S)
%
% Input
%  S - @complianceTensor
%
% Output
%  GV - shear modulus Voigt average, upper bound
%  GR - shear modulus Reuss average, lower bound
%  GVRH - shear modulus Voigt Reuss Hill average, ￼

% compute stifness tensor as 6x6 matrices
C = matrix(inv(S),'voigt');
S = matrix(S,'voigt');

% GV = ((C(1,1)+C(2,2)+C(3,3))-(C(1,2)+C(2,3)+C(3,1))+3*(C(4,4)+C(5,5)+C(6,6)))/15
GV= ((C(1,1,:) + C(2,2) + C(3,3,:)) ...
  - (C(1,2,:) + C(2,3,:) + C(3,1,:)) ...
  + 3 * (C(4,4,:) + C(5,5,:) + C(6,6,:))) ./ 15;

% GR = 15/(4*(S(1,1)+S(2,2)+S(3,3))-4*(S(1,2)+S(2,3)+S(3,1))+3*(S(4,4)+S(5,5)+S(6,6)))
GR = 15 ./ (4 * (S(1,1,:) + S(2,2,:) + S(3,3,:)) ...
  - 4 * (S(1,2,:) + S(2,3,:) + S(3,1,:)) ...
  + 3 * (S(4,4,:) + S(5,5,:) + S(6,6,:)));

% Voigt Reuss Hill average
GVRH = 0.5.*(GV + GR);

end