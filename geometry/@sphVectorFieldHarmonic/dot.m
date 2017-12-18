function sF = dot(sVF1, sVF2, varargin)
% pointwise inner product
%
% Syntax
%   d = dot(sVF1, sVF2)
%
% Input
%  sVF1, sVF2 - @sphVectorField
%
% Options
%  M - degree of the spherical harmonic
%
% Output
%  sF - @sphFun

sF = sphFunHarmonic.quadrature( ...
  @(v) dot(sVF1.eval(v), sVF2.eval(v)), ...
  varargin{:});
