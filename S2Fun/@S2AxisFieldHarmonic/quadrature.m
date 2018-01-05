function sVF = quadrature(f, varargin)
%
% Syntax
%  sF = S2VectorField.quadrature(v, value)
%  sF = S2VectorField.quadrature(f)
%  sF = S2VectorField.quadrature(f, 'bandwidth', M)
%
% Input
%  value - @vector3d
%  v - @vector3d
%  f - function handle in @vector3d
%
% Options
%  M - degree of the spherical harmonic (default: 128)
%

if isa(f,'vector3d')
  nodes = f;
  values = getClass(varargin,'vector3d'); % function values
  [x,y,z] = double(values);
  Ma = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
  sF = S2FunHarmonic.quadrature(nodes, Ma, varargin{:});
else
  sF = S2FunHarmonic.quadrature(@(nodes) g(nodes), varargin{:});
end

sVF = S2AxisFieldHarmonic(sF);

function Ma = g(nodes)
v = f(nodes);
[x,y,z] = double(v);
Ma = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
end

end
