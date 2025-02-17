function sVF = interpolate(v, y, varargin)
% Interpolate an S2VectorField by given tangent vectors at given points on
% the sphere.
%
% Syntax
%   sVF = S2VectorField.interpolate(v, value)
%   sVF = S2VectorField.interpolate(v, value, 'bandwidth', bw)
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
% See also
% vector3d/interp S2FunHarmonic/interpolate

y = y.xyz;
sF = S2FunHarmonic.interpolate(v, y, varargin{:});

sVF = S2VectorFieldHarmonic(sF);

end
