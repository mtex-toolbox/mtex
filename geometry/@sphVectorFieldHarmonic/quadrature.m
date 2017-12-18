function sVF = quadrature(f, varargin)
%
% Syntax
%  sF = sphVectorField.quadrature(v, value)
%  sF = sphVectorField.quadrature(f)
%  sF = sphVectorField.quadrature(f, 'm', M)
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
  M2 = 2*M;
  v = f(:);
  y = getClass(varargin,'vector3d'); y = y(:); % function values
else
  if check_option(varargin, 'gauss')
    [v, W, M2] = quadratureS2Grid(2*M, 'gauss');
  else
    [v, W, M2] = quadratureS2Grid(2*M);
  end
  y = W(:).*f(v(:));
end

sVF = sphVectorFieldHarmonic( ...
  sphFunHarmonic.quadrature(dot(y, sphVectorField.theta(v)), v), ...
  sphFunHarmonic.quadrature(dot(y, sphVectorField.rho(v)), v), ...
  sphFunHarmonic.quadrature(dot(y, sphVectorField.n(v)), v));

end
