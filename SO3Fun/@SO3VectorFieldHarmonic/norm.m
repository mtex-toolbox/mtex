function SO3F = norm(SO3VF)
% point-wise norm of the vector field
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

if SO3VF.bandwidth == 0
  SO3F = SO3FunHarmonic(0,SO3VF.hiddenCS,SO3VF.hiddenSS);
  return
end

SO3F = SO3FunHarmonic.quadrature(@(rot) norm(SO3VF.eval(rot)), ...
  SO3VF.hiddenCS,SO3VF.hiddenSS,'bandwidth',SO3VF.bandwidth);

end
