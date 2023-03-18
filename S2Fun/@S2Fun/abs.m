function sF = abs(sF, varargin)
% absolute value of a function
% Syntax
%   sF = abs(sF)
%   sF = abs(sF, 'bandwidth', bandwidth)
%
% Input
%  sF - @S2Fun
%
% Output
%  sF - @S2FunHandle
%
% Options
%  bandwidth - minimal degree of the spherical harmonic
%

sF = S2FunHandle(@(v) abs(sF.eval(v)));

end
