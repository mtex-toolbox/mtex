function SO3F = Fourier(T,varargin)
% compute rotated tensor as SO3Fun
%
% Description
%
% Input
%  T - @tensor
%
% Output
%  SO3F - @SO3FunHarmonic
%

fun = @(o) permute(double(o .* T),[T.rank+1,1:T.rank]);

SO3F = SO3FunHarmonic.quadrature(fun,T.CS,'bandwidth',T.rank);
