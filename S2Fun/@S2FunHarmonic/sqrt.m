function sF = sqrt(sF, varargin)
% square root of a function
% Syntax
%   sF = sqrt(sF)
%   sF = sqrt(sF, 'bandwidth', bandwidth)
%
% Input
%  sF - @S2FunHarmonic
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - minimal degree of the spherical harmonic
%

sF = sF.quadrature(@(v) sqrt(sF.eval(v)),varargin{:});

end
