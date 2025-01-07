function sF = log(sF)
% overloads |log(sF)|
%
% Syntax
%   sF = log(sF)
%
% Input
%  sF - @S1Fun
%
% Output
%  sF - @S1Fun
%

sF = S1FunHandle(@(o) log(sF.eval(o)));

end