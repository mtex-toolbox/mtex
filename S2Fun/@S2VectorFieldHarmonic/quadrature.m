function sVF = quadrature(f, varargin)
% Compute the S2-Fourier/harmonic coefficients of an given @S2VectorField or
% given evaluations on a specific quadrature grid.
%
% Syntax
%   sVF = S2VectorField.quadrature(v, value)
%   sVF = S2VectorField.quadrature(f)
%   sVF = S2VectorField.quadrature(f, 'bandwidth', bw)
%
% Input
%   value - @vector3d
%   v - @vector3d
%   f - @S2VectorField, @function_handle in vector3d
%
% Output
%   sVF - @S2VectorFieldHarmonic
%
% Options
%   bw - degree of the spherical harmonic (default: 128)
%
% See also
% S2VectorFieldHarmonic/approximate S2VectorFieldHarmonic
% S2FunHarmonic.quadrature


if isa(f,'vector3d')
  v = f;
  y = getClass(varargin,'vector3d'); % function values
  
  if y.antipodal 
    sVF = S2AxisFieldHarmonic.quadrature(v, y, varargin{:});
    return
  else
    sF = S2FunHarmonic.quadrature(v, y.xyz, varargin{:});
  end
else
  sF = S2FunHarmonic.quadrature(@(v) g(v), varargin{:});
end

sVF = S2VectorFieldHarmonic(sF);

function g = g(v)
  if isa(f,'S2VectorField')
    g = f.eval(v);
  else
    g = f(v);
  end
  g = g.xyz;
end

end
