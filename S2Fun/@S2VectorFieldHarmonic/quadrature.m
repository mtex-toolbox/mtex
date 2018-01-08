function sVF = quadrature(f, varargin)
%
% Syntax
%   sVF = S2VectorField.quadrature(v, value)
%   sVF = S2VectorField.quadrature(f)
%   sVF = S2VectorField.quadrature(f, 'm', M)
%
% Input
%   value - @vector3d
%   v - @vector3d
%   f - function handle in @vector3d
%
% Output
%   sVF - @S2VectorFieldHarmonic
%
% Options
%   M - degree of the spherical harmonic (default: 128)
%

M = get_option(varargin, 'm', 128);
if isa(f,'vector3d')
  v = f;
  y = getClass(varargin,'vector3d'); % function values
  y = y.xyz;
  sF = S2FunHarmonic.quadrature(v, y, varargin{:});
else
  sF = S2FunHarmonic.quadrature(@(v) g(v), varargin{:});
end

sVF = S2VectorFieldHarmonic(sF);

function g = g(v)
g = f(v);
g = g.xyz;
end

end
