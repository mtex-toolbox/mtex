function varargout = linearCompressibility(C,varargin)
% computes the linear compressibility of an elasticity tensor
%
% Description
%
% $$\beta(x) = S_{ijkk} x_i x_j$$
%
% Input
%  C - elastic @stiffnessTensor
%  x - list of @vector3d
%
% Output
%  beta - linear compressibility in directions v
%

% compute linear compressibility from complience
[varargout{1:nargout}] = linearCompressibility(inv(C),varargin{:});
