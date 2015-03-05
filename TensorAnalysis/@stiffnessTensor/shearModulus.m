function E = shearModulus(C,h,u)
% shear modulus for an elasticity tensor
%
% Description
%
% $$G = \frac{1}{4 S_{ijkl} h_i u_j h_k u_l}$$
%
% Input
%  C - elastic @stiffnessTensor
%  h - shear plane @vector3d
%  u - shear direction @vector3d
%
% Output
%  E - shear modulus
%
% See also
% tensor/YoungsModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% compute the compliance tensor
S = inv(C);

% compute directional magnitude
E = 0.25./matrix(EinsteinSum(S,[-1 -2 -3 -4],h,-1,u,-2,h,-3,u,-4));
