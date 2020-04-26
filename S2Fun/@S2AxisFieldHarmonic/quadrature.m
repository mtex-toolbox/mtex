function sAF = quadrature(f, varargin)
%
% Syntax
%   sF = S2AxisField.quadrature(v, value)
%   sF = S2AxisField.quadrature(f)
%   sF = S2AxisField.quadrature(f, 'bandwidth', M)
%
% Input
%  v - @vector3d 
%  value - @vector3d (antipodal)
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

sAF = S2AxisFieldHarmonic(sF);

function Ma = g(nodes)
  
  if isa(f,'function_handle')
    v = f(nodes);
  else
    v = f.eval(nodes);
  end
  
  [x,y,z] = double(v);
  Ma = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
  
end

end
