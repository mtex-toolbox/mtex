function varargout = shearModulus(C,varargin)
% shear modulus for an elasticity tensor
%
% Syntax
%   E = shearModulus(C,h,u)
%   E = shearModulus(C,[],u)
%   E = shearModulus(C,h,[])
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

% take formula using complience
[varargout{1:nargout}] = shearModulus(inv(C),varargin{:});