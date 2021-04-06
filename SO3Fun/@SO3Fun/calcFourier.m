function f_hat = calcFourier(SO3F,varargin)
% compute harmonic coefficients of SO3Fun
%
% Syntax
%
%  f_hat = calcFourier(SO3F)
%
%  f_hat = calcFourier(SO3F,'bandwidth',L)
%
% Input
%  SO3F - @SO3Fun
%     L - maximum harmonic degree
%
% Output
%  f_hat - harmonic/Fouier/Wigner-D coefficients
%

L = get_option(varargin,'bandwidth',SO3F.bandwidth);

% TODO: do this with quadrature
