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
%  SO3F - @SO3FunHarmonic
%

SO3F = SO3FunHarmonic.quadrature(@(rot) norm(SO3VF.eval(rot)).^2,...
  SO3VF.CS,SO3VF.SS,'bandwidth',2 * SO3VF.bandwidth);

end
