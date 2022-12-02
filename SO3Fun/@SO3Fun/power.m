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

if ~isnumeric(a)
  error('The exponent has to be numeric.')
end

SO3F = SO3FunHandle(@(rot) SO3F.eval(rot).^reshape(a,[1 size(a)]),SO3F.SRight,SO3F.SLeft);


end