function sF = log(sF, varargin)
% log of a function
%
% Syntax
%   sF = log(sF)
%   sF = log(sF, 'bandwidth', bandwidth)
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

sF = sF.quadrature(@(v) log(sF.eval(v)),varargin{:});

end
