function varargout = volumeCompressibility(C,varargin)
% volume compressibility of an elasticity stiffness tensor
%
% Syntax
%   beta = volumeCompressibility(C)
%
% Input
%  C - elastic stiffness @tensor
%
% Output
%  beta - volume compressibility
%
% Description
%
% $$\beta(x) = S_{iikk}$$
%

% take formula using complience
[varargout{1:nargout}] = volumeCompressibility(inv(C),varargin{:});