function SO3VF = power(SO3VF,a)
% overloads |SO3VF.^2|
%
% Syntax
%   SO3VF = SO3VF.^2
%
% Input
%  SO3VF - @SO3VectorField
%  a - double
%
% Output
%  SO3VF - @SO3VectorField
%

if isa(a,'vector3d')
  a = a.xyz;
end

if ~isnumeric(a)
  error('The exponent has to be numeric.')
end

SO3VF = SO3VectorFieldHandle(@(rot) SO3VF.eval(rot).^(a(:)),SO3VF.SRight,SO3VF.SLeft);


end