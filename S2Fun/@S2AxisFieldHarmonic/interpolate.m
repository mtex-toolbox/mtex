function sAF = interpolate(v, y, varargin)
% Interpolate an axis field by given axis vectors at given nodes on
% the sphere by doing componentwise spherical interpolation.
%
% Syntax
%   sAF = S2AxisFieldHarmonic.interpolate(v, value)
%   sAF = S2AxisFieldHarmonic.interpolate(v, value, 'bandwidth', bw)
%
% Input
%  value - @vector3d
%  v - @vector3d (antipodal)
%
% Output
%  sAF - @S2AxisFieldHarmonic
%
% Options
%  bw - degree of the spherical harmonic (default: 128)
%
% See also
% vector3d/interp S2FunHarmonic/interpolate

[x,y,z] = double(y);
Ma = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
sF = S2FunHarmonic.interpolate(v, Ma, varargin{:});

sAF = S2AxisFieldHarmonic(sF);

end
