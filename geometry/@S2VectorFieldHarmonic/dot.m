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

if isa(sVF1, 'vector3d')
  f = @(v) dot(sVF1, sVF2.eval(v));
elseif isa(sVF2, 'vector3d')
  f = @(v) dot(sVF1.eval(v), sVF2);
else
  f = @(v) dot(sVF1.eval(v), sVF2.eval(v));
end

sF = S2FunHarmonic.quadrature(f, varargin{:});

end
