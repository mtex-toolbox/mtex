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
%  SO3F - @SO3FunCBF
%     L - maximum harmonic degree
%
% Output
%  f_hat - harmonic/Fourier/Wigner-D coefficients
%

L = min(SO3F.bandwidth, get_option(varargin,'bandwidth',NaN));
SO3F.bandwidth = L;

f_hat = SO3F.fhat;

