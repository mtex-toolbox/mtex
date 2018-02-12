function E = shearModulus(S,h,u)
% shear modulus for an compliance tensor
%
% Syntax
%   E = shearModulus(S,h,u)
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
%
% Description
%
% $$G = \frac{1}{4 S_{ijkl} h_i u_j h_k u_l}$$
%
% See also
% tensor/YoungsModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% generate a function if required
if nargin == 1 || isempty(h)
  
  E = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(S,v,u),'bandwidth',4,S.CS);
    
elseif nargin <= 2 || isempty(u)

  E = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(S,h,v),'bandwidth',4,S.CS);
    
else

  % compute shear modulus
  E = 0.25./EinsteinSum(S,[-1 -2 -3 -4],h,-1,u,-2,h,-3,u,-4);
  
end