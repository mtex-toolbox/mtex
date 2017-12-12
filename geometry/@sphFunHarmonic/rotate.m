function sF = rotate(sF, varargin)
% rotate a function by rot
% Syntax
%  sF = sF.rotate(rot)
%  sF = sF.rotate(rot, 'm', M)
%
% Input
%  sF - spherical function
%  rot - rotation
%
% Options
%  M - minimal degree of the spherical harmonic
%

rot = varargin{1};
M = get_option(varargin, 'm', min(sF.M, 500));

f = @(v) sF.eval(v.rotate(rot));
sF = sphFunHarmonic.quadrature(f, 'm', max(M, 100));

end
