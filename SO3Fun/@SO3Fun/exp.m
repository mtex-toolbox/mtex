function SO3F = exp(SO3F)
% overloads |exp(SO3F)|
%
% Syntax
%   SO3F = exp(SO3F)
%
% Input
%  SO3F - @SO3Fun
%
% Output
%  SO3F - @SO3Fun
%

SO3F = SO3FunHandle(@(rot) exp(SO3F.eval(rot)),SO3F.SRight,SO3F.SLeft);

end