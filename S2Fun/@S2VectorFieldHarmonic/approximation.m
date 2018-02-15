function sVF = approximation(v, y, varargin)
%
% Syntax
%   sVF = S2VectorField.quadrature(v, value)
%   sVF = S2VectorField.quadrature(v, value, 'bandwidth', bw)
%
% Input
%   value - @vector3d
%   v - @vector3d
%
% Output
%   sVF - @S2VectorFieldHarmonic
%
% Options
%   bw - degree of the spherical harmonic (default: 128)
%

y = y.xyz;
sF = S2FunHarmonic.quadrature(v, y, varargin{:});

sVF = S2VectorFieldHarmonic(sF);

end
