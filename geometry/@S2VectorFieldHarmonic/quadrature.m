function sVF = quadrature(f, varargin)
%
% Syntax
%  sF = S2VectorField.quadrature(v, value)
%  sF = S2VectorField.quadrature(f)
%  sF = S2VectorField.quadrature(f, 'm', M)
%
% Input
%  value - @vector3d
%  v - @vector3d
%  f - function handle in @vector3d
%
% Options
%  M - degree of the spherical harmonic (default: 128)
%

M = get_option(varargin, 'm', 128);
if isa(f,'vector3d')
  v = f(:);
  y = getClass(varargin,'vector3d'); y = y(:); % function values
else
  if check_option(varargin, 'gauss')
    [v, W] = quadratureS2Grid(2*M, 'gauss');
  else
    [v, W] = quadratureS2Grid(2*M);
  end
  y = W(:).*f(v(:));
end

sVF = S2VectorFieldHarmonic( ...
  S2FunHarmonic.quadrature(dot(y, S2VectorField.theta(v)), v), ...
  S2FunHarmonic.quadrature(dot(y, S2VectorField.rho(v)), v), ...
  S2FunHarmonic.quadrature(dot(y, S2VectorField.n(v)), v));

end
