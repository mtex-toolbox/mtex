function sF = mtimes(sF1,sF2)
% implements |sF1 * alpha| and |alpha*sF2| as matrix product
%
% Syntax
%   sF = a * sF1
%   sF = sF1 * [1;1]
%
% Input
%  sF1, sF2 - @S1Fun
%  a - double
%
% Output
%  sF - @S1Fun
%

if isnumeric(sF1)
  sF = (sF2.' * sF1.').';
  return
end
if isnumeric(sF2) && (isscalar(sF1) || isscalar(sF2))
  sF = sF1 .* sF2;
  return
end
if isnumeric(sF2)
  sF = S1FunHarmonic(sF1);
  sF2 = reshape(sF2,[1 1 size(sF2)]);
  sF.fhat = sum(sF.fhat .* sF2,3);
  s = size(sF.fhat);
  sF.fhat = reshape(sF.fhat,s(1),s(2),[]);
  return
end

error('Operator * is not supported for operands of this types. Use .* or conv() instead.')

end