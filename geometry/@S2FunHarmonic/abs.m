function sF = abs(sF, varargin)
% absolute value of a function
% Syntax
%  sF = abs(sF)
%  sF = abs(sF, 'bandwidth', bandwidth)
%
% Input
%  sF - spherical function
%
% Options
%  bandwidth - minimal degree of the spherical harmonic
%

bandwidth = get_option(varargin, 'bandwidth', min(2*sF.bandwidth, 500);

f = @(v) abs(sF.eval(v));
sF = S2FunHarmonic.quadrature(f, 'bandwidth', max(bandwidth, 100));

end
