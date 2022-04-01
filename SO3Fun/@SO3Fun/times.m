function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F2
%   sF = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  dim = length(size(SO3F1));
  SO3F = SO3FunHandle(@(rot) permute(SO3F1,[dim+1 1:dim]) .* SO3F2.eval(rot),SO3F2.CS,SO3F2.SS);
  return
end

if isnumeric(SO3F2)
  SO3F = SO3F2 .* SO3F1;
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .* SO3F2.eval(rot),SO3F1.SRight,SO3F1.SLeft);

end