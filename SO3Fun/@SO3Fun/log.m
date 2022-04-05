function SO3F = log(SO3F)
% overloads |log(SO3F)|
%
% Syntax
%   SO3F = log(SO3F)
%
% Input
%  SO3F - @SO3Fun
%
% Output
%  SO3F - @SO3Fun
%

SO3F = SO3FunHandle(@(rot) log(SO3F.eval(rot)),SO3F.SRight,SO3F.SLeft);

end