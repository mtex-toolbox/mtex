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


% do quadrature
fun = @(rot) reshape( norm(vector3d(SO3VF.SO3F.eval(rot))).^2 , size(rot));
bw = min(getMTEXpref('maxSO3Bandwidth'),2*SO3VF.bandwidth);
SO3F = SO3FunHarmonic.quadrature(fun,SO3VF.hiddenCS,SO3VF.hiddenSS,'bandwidth',bw);

end
