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

if SO3VF.bandwidth == 0
  SO3F = SO3FunHarmonic(0,SO3VF.hiddenCS,SO3VF.hiddenSS);
  return
end

SO3F = SO3FunHarmonic.quadrature(@(rot) norm(SO3VF.eval(rot)).^2,...
  SO3VF.hiddenCS,SO3VF.hiddenSS,'bandwidth',min(getMTEXpref('maxSO3Bandwidth'),2*SO3VF.bandwidth));

end
