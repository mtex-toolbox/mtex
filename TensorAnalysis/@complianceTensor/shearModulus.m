function [E,GReuss,GHill] = shearModulus(S,h,u)
% shear modulus for an compliance tensor
%
% Syntax
%
%   [GV,GR,GVRH] = shearModulus(S) % the isotropic case
%
%   E = shearModulus(S,h,u) % the anisotropic case with plane h and shear direction  u
%   E = shearModulus(S,[],u)
%   E = shearModulus(S,h,[])
%
% Input
%  C - elastic @stiffnessTensor
%  h - shear plane @vector3d
%  u - shear direction @vector3d
%
% Output
%  E - shear modulus
%  GVoigt - Voigt effective shear modulus, upper bound
%  GReuss - Reuss effective shear modulus, lower bound
%  GHill - Hill effective shear modulus
%
% Description
%
% $$E = \frac{1}{4 S_{ijkl} h_i u_j h_k u_l}$$
%
% See also
% complianceTensor/YoungsModulus complianceTensor/volumeCompressibility complianceTensor/ChristoffelTensor


if nargin == 1 % the isotropic case
  
  % compute stifness tensor as 6x6 matrices
  C = matrix(inv(S),'voigt');
  S = matrix(S,'voigt');

  % the Voigt upper bound
  % GV = ((C(1,1)+C(2,2)+C(3,3))-(C(1,2)+C(2,3)+C(3,1))+3*(C(4,4)+C(5,5)+C(6,6)))/15
  GVoigt = ((C(1,1,:) + C(2,2) + C(3,3,:)) ...
    - (C(1,2,:) + C(2,3,:) + C(3,1,:)) ...
    + 3 * (C(4,4,:) + C(5,5,:) + C(6,6,:))) ./ 15;

  % the Reuss lower bound
  % GR = 15/(4*(S(1,1)+S(2,2)+S(3,3))-4*(S(1,2)+S(2,3)+S(3,1))+3*(S(4,4)+S(5,5)+S(6,6)))
  GReuss = 15 ./ (4 * (S(1,1,:) + S(2,2,:) + S(3,3,:)) ...
    - 4 * (S(1,2,:) + S(2,3,:) + S(3,1,:)) ...
    + 3 * (S(4,4,:) + S(5,5,:) + S(6,6,:)));

  % Voigt Reuss Hill average
  GHill = 0.5.*(GVoigt + GReuss);
  E = GVoigt;
    
elseif nargin == 2 || isempty(h)
  
  E = S2FunHarmonicSym.quadrature(@(u) shearModulus(S,h,u),'bandwidth',4,S.CS);
    
elseif isempty(u)

  E = S2FunHarmonicSym.quadrature(@(u) shearModulus(S,h,u),'bandwidth',4,S.CS);
    
else

  % the anisotropic shear modulus
  E = 0.25./EinsteinSum(S,[-1 -2 -3 -4],h,-1,u,-2,h,-3,u,-4);
  
end