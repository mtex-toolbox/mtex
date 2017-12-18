function sVF = cross(sVF1, sVF2, varargin)
% pointwise cross product
%
% Syntax
%  sVF = cross(sVF1, sVF2)
%
% Input
%  sVF1, sVF2 - @sphVectorField
% Output
%  sVFv - @sphVectorField
%

sVF = sphVectorFieldHarmonic.quadrature( ...
  @(v) cross(sVF1.eval(v), sVF2.eval(v)), ...
  varargin{:});
