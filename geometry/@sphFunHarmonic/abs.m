function sF = abs(sF, varargin)
% absolute value of a function
% Syntax
%  sF = abs(sF)
%  sF = abs(sF, 'm', M)
%
% Input
%  sF - spherical function
%
% Options
%  M - minimal degree of the spherical harmonic
%

M = get_option(varargin, 'm', min(2*sF.M, 500);

f = @(v) abs(sF.eval(v));
sF = sphFunHarmonic.quadrature(f, 'm', max(M, 100));

end
