function f_hat = calcFourier(SO3F,L,varargin)
% compute harmonic coefficients of SO3Fun
%
% Syntax
%
%  f_hat = calcFourier(SO3F)
%
%  f_hat = calcFourier(SO3F,L)
%
% Input
%  SO3F - @SO3Fun
%     L - maximum harmonic degree
%
% Output
%  f_hat - harmonic/Fouier/Wigner-D coefficients
%

if nargin == 1, L = SO3F.bandwidth; end

% TODO: do this with quadrature
