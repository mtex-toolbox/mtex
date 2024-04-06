function SO3VF = mtimes(SO3VF1,SO3VF2)
% implements |SO3VF1 * alpha| and |alpha*SO3VF2| as matrix product
%
% Syntax
%   SO3VF = a * SO3VF1
%   SO3VF = SO3VF1 * a
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%  a - double
%
% Output
%  SO3VF - @SO3VectorField
%

if (isnumeric(SO3VF1) && isscalar(SO3VF1)) || (isnumeric(SO3VF2) && isscalar(SO3VF2))
  SO3VF = SO3VF1 .* SO3VF2;
  return
end

error('Operator * is not supported for operands of this types. Use .* or conv() instead.')

end