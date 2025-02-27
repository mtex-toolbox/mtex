function SO3F = normSquare(SO3VF)
% pointwise norm of the vector field
%
% Syntax
%   SO3F = normSquare(SO3VF)
%
% Input
%  SO3VF - @SO3VectorFieldRBF 
%
% Output
%  SO3F - @SO3FunRBF
%

f = SO3VectorFieldHandle(@(r) norm(SO3VF.eval(r)).^2,SO3VF.CS,SO3VF.SS);
SO3F = SO3FunRBF.approximate(f,SO3VF.CS,SO3VF.SS);

end
