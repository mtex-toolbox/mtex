function E = shearModulus(C,h,u)
% shear modulus for an elasticity tensor
%
% Description
%
% $$G = \frac{1}{4 S_{ijkl} h_i u_j h_k u_l}$$
%
% Input
%  C - elastic stiffness @tensor
%  h - shear plane @vector3d
%  u - shear direction @vector3d
%
% Output
%  E - shear modulus
%
% See also
% tensor/YoungsModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% generate a function if required
if nargin == 1 || isempty(h)
  
  E = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(C,v,u),'M',4,C.CS);
    
elseif nargin <= 2 || isempty(u)

  E = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(C,h,v),'M',4,C.CS);
    
else

  % compute the compliance tensor
  S = inv(C);

  % compute shear modulus
  E = 0.25./matrix(EinsteinSum(S,[-1 -2 -3 -4],h,-1,u,-2,h,-3,u,-4));
  
end