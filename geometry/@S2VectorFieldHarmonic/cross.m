function sVF = cross(sVF1, sVF2, varargin)
% pointwise cross product
%
% Syntax
%  sVF = cross(sVF1, sVF2)
%
% Input
%  sVF1, sVF2 - @S2VectorField
% Output
%  sVFv - @S2VectorField
%

sVF = S2VectorFieldHarmonic.quadrature( ...
  @(v) cross(sVF1.eval(v), sVF2.eval(v)), ...
  varargin{:});
