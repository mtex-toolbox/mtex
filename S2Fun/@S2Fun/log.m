function sF = log(sF, varargin)
% log of a function
%
% Syntax
%   sF = log(sF)
%
% Input
%  sF - @S2Fun
%
% Output
%  sF - @S2FunHandle
%


sF = S2FunHandle(@(v) log(sF.eval(v)));

end
