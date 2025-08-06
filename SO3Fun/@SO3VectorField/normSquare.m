function SO3F = normSquare(SO3VF)
% pointwise norm of the vector field
%
% Syntax
%   SO3F = normSquare(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField 
%
% Output
%  SO3F - @SO3Fun
%

SO3F = SO3FunHandle(@(rot) norm(SO3VF.eval(rot)).^2,SO3VF.hiddenCS,SO3VF.hiddenSS);

end