function sF = cos(sF, varargin)
% cost of a function
% Syntax
%   sF = cos(sF)
%   sF = cos(sF, 'bandwidth', bandwidth)
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

sF = sF.quadrature(@(v) cos(sF.eval(v)),varargin{:});

end
