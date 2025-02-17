function sAF = quadrature(f, varargin)
% Compute the S2-Fourier/harmonic coefficients of an given @S2AxisField or
% given evaluations on a specific quadrature grid, by componentwise 
% spherical quadrature.
%
% Syntax
%   sF = S2AxisFieldHarmonic.quadrature(v, value)
%   sF = S2AxisFieldHarmonic.quadrature(f)
%   sF = S2AxisFieldHarmonic.quadrature(f, 'bandwidth', bw)
%
% Input
%  v - @vector3d 
%  value - @vector3d (antipodal)
%  f - function handle in @vector3d
%
% Options
%  bw - maximal degree of the spherical harmonic (default: 128)
%
% See also
% S2AxisFieldHarmonic/approximate S2AxisFieldHarmonic

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
