function f_hat = calcFourier(sF,varargin)
% compute harmonic coefficients of S1Fun
%
% Syntax
%   f_hat = calcFourier(sF)
%   f_hat = calcFourier(sF,'bandwidth',L)
%
% Input
%  sF - @S1Fun
%  L - maximum degree
%
% Output
%  f_hat - Fourier coefficients
%

sF = S1FunHarmonic.quadrature(sF,varargin{:});
f_hat = sF.fhat;