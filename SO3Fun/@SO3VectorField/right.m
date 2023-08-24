function SO3VF = right(SO3VF)
% change the representation of the tangent vectors to right sided
%
% Syntax
%   SO3VF = right(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField  (the evaluation directly gives right-sided tangent vectors)
%

if strcmp(SO3VF.tangentSpace,'right')
  return
end

SO3VF = SO3VectorFieldHandle(@(r) inv(r).*SO3VF.eval(r) ,SO3VF.CS,SO3VF.SS,'right');

end