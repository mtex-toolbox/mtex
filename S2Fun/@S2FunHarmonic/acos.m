function sF = acos(sF, varargin)
% cost of a function
% Syntax
%   sF = acos(sF)
%   sF = acos(sF, 'bandwidth', bandwidth)
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

sF = sF.quadrature(@(v) acos(max(-1,min(1,sF.eval(v)))),varargin{:});

end
