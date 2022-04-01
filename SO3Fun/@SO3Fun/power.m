function SO3F = power(SO3F,a)
% overloads |SO3F.^2|
%
% Syntax
%   SO3F = SO3F.^2
%
% Input
%  SO3F - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

SO3F = SO3FunHandle(@(rot) SO3F.eval(rot).^a,SO3F.SRight,SO3F.SLeft);


end