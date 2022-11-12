function SO3VF = quadrature(f, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.quadrature(rot, value)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f, 'bandwidth', bw)
%
% Input
%   rot - @rotation, @orientation
%   value - @vector3d
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
  SO3VF = SO3VectorFieldHarmonic(SO3F);
  return
end

if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

SO3F = SO3FunHarmonic.quadrature(@(rot) g(rot),f.CS,f.SS,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F);


function g = g(rot)
g = f.eval(rot);
g = g.xyz;
end

end
