function varargout = YoungsModulus(C,varargin)
% Young's modulus for an elasticity tensor
%
% Syntax
%   E = YoungsModulus(C)
%   E = YoungsModulus(C,x)
%
% Input
%  C - elastic stiffness @tensor
%  x - list of @vector3d
%
% Output
%  E - Youngs modulus
%
% Description
%
% $$E = \frac{1}{S_{ijkl} x_i x_j x_k x_l}$$
%
% See also
% tensor/shearModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% take formula using complience
[varargout{1:nargout}] = YoungsModulus(inv(C),varargin{:});
