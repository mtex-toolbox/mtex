function sF = log2(sF, varargin)
% pointwise log2 of a function
%
% Syntax
%   sF = log2(sF)
%
% Input
%  sF - @S2Fun
%
% Output
%  sF - @S2FunHandle
%


sF = S2FunHandle(@(v) log2(sF.eval(v)));

end
