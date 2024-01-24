function SO3VF = left(SO3VF)
% change the representation of the tangent vectors to left sided
%
% Syntax
%   SO3VF = left(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField  (the evaluation directly gives left-sided tangent vectors)
%

if strcmp(SO3VF.tangentSpace,'left')
  return
end

SO3VF = SO3VectorFieldHandle(@(r) r.*SO3VF.eval(r) ,SO3VF.CS,SO3VF.SS,'left');

end