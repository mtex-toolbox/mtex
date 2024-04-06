function SO3F = mtimes(SO3F1,SO3F2)
% implements |SO3F1 * alpha| and |alpha*SO3F2| as matrix product
%
% Syntax
%   SO3F = a * SO3F1
%   SO3F = SO3F1 * [1;1]
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  SO3F = (SO3F2.' * SO3F1.').';
  return
end
if isnumeric(SO3F2) && (isscalar(SO3F1) || isscalar(SO3F2))
  SO3F = SO3F1 .* SO3F2;
  return
end
if isnumeric(SO3F2)
  SO3F = SO3FunHarmonic(SO3F1);
  SO3F2 = reshape(SO3F2,[1 1 size(SO3F2)]);
  SO3F.fhat = sum(bsxfun(@times,SO3F.fhat,SO3F2),3);
  s = size(SO3F.fhat);
  SO3F.fhat = reshape(SO3F.fhat,s(1),s(2),[]);
  return
end

error('Operator * is not supported for operands of this types. Use .* or conv() instead.')

end