function sAF = approximate(v, y, varargin)
%
% Syntax
%   sAF = S2AxisField.approximate(v, value)
%   sAF = S2AxisField.approximate(v, value, 'bandwidth', bw)
%
% Input
%   value - @vector3d
%   v - @vector3d (antipodal)
%
% Output
%   sAF - @S2AxisFieldHarmonic
%
% Options
%   bw - degree of the spherical harmonic (default: 128)
%

[x,y,z] = double(y);
Ma = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
sF = S2FunHarmonic.approximate(v, Ma, varargin{:});

sAF = S2AxisFieldHarmonic(sF);

end
