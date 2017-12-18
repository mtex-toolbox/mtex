function E = YoungsModulus(C,varargin)
% Young's modulus for an elasticity tensor
%
% Description
%
% $$E = \frac{1}{S_{ijkl} x_i x_j x_k x_l}$$
%
% Syntax
%  E = YoungsModulus(C)
%  E = YoungsModulus(C,x)
%
% Input
%  C - elastic stiffness @tensor
%  x - list of @vector3d
%
% Output
%  E - Youngs modulus
%  E - @sphFun
%
% See also
% tensor/shearModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% compute the compliance tensor
S = inv(C);

% compute directional magnitude
E = 1./directionalMagnitude(S,varargin{:});
