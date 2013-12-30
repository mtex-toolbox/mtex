function E = YoungsModulus(C,x)
% Young's modulus for an elasticity tensor
%
% Description
%
% $$E = \frac{1}{S_{ijkl} x_i x_j x_k x_l}$$
%
% Input
%  C - elastic stiffness @tensor
%  x - list of @vector3d
%
% Output
%  E - Youngs modulus
%
% See also
% tensor/shearModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% compute the compliance tensor
S = inv(C);

% compute directional magnitude
E = 1./directionalMagnitude(S,x);
