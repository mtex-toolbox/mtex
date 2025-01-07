function sF = exp(sF)
% overloads |exp(sF)|
%
% Syntax
%   sF = exp(sF)
%
% Input
%  sF - @S1Fun
%
% Output
%  sF - @S1Fun
%

sF = S1FunHandle(@(o) exp(sF.eval(o)));

end