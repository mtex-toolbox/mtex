function SO3F = norm(SO3VF)
% pointwise norm of the vector field
%
% Syntax
%   SO3F = norm(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField 
%
% Output
%  SO3F - @SO3FunHarmonic
%

SO3F = SO3FunHarmonic.quadrature(@(rot) norm(SO3VF.eval(rot)),SO3VF.CS,SO3VF.SS);

end
