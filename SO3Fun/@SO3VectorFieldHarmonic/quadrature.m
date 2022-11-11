function SO3VF = quadrature(f, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.quadrature(rot, value)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f, 'bandwidth', bw)
%
% Input
%   value - @vector3d
%   rot - @rotation
%   f - function handle in @SO3VectorField
%
% Output
%   SO3VF - @SO3VectorFieldHarmonic
%
% Options
%   bw - degree of the Wigner-D functions (default: 128)
%

if isa(f,'rotation')
  v = f;
  y = getClass(varargin,'vector3d'); % function values
  y = y.xyz;
  SO3F = SO3FunHarmonic.quadrature(v, y, varargin{:});
else
  SO3F = SO3FunHarmonic.quadrature(@(rot) g(rot), varargin{:});
end

SO3VF = SO3VectorFieldHarmonic(SO3F);

function g = g(rot)
g = f.eval(rot);
g = g.xyz;
end

end
