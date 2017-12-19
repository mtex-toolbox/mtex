function sF = dot(sVF1, sVF2, varargin)
% pointwise inner product
%
% Syntax
%   d = dot(sVF1, sVF2)
%
% Input
%  sVF1, sVF2 - @S2VectorField
%
% Options
%  M - degree of the spherical harmonic
%
% Output
%  sF - @S2Fun

sF = S2FunHarmonic.quadrature( ...
  @(v) dot(sVF1.eval(v), sVF2.eval(v)), ...
  varargin{:});
