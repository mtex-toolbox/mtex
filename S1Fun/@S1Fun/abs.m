function sF = abs(sF)
% absolute value of an S1Fun
% 
% Syntax
%   sF = abs(sF)
%
% Input
%  sF - @S1Fun
%
% Output
%  sF - @S1Fun
%

sF = S1FunHandle(@(o) abs(sF.eval(o)));