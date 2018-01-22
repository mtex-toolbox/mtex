function sVF = cross(sVF1, sVF2, varargin)
% pointwise cross product
%
% Syntax
%   sVF = cross(sVF1, sVF2)
%
% Input
%   sVF1, sVF2 - @S2VectorField
%
% Output
%   sVF - @S2VectorFieldHarmonic
%

if isa(sVF1, 'vector3d')
  f = @(v) cross(sVF1, sVF2.eval(v));
elseif isa(sVF2, 'vector3d')
  f = @(v) cross(sVF1.eval(v), sVF2);
else
  f = @(v) cross(sVF1.eval(v), sVF2.eval(v));
end

sVF = S2VectorFieldHarmonic.quadrature(f, varargin{:});

end
