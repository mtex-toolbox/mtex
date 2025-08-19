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

% do quadrature
fun = @(rot) reshape( norm(vector3d(SO3VF.SO3F.eval(rot))) , size(rot));
SO3F = SO3FunHarmonic.quadrature(fun,SO3VF.hiddenCS,SO3VF.hiddenSS,'bandwidth',SO3VF.bandwidth);

end
