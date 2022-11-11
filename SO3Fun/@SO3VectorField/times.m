function SO3VF = times(SO3VF1,SO3VF2)
% overloads |SO3VF1 .* SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 .* SO3VF2
%   SO3VF = a .* SO3VF2
%   SO3VF = SO3VF1 .* a
%   SO3VF = SO3F .* SO3VF1
%   SO3VF = SO3VF1 .* SO3F
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%  a - double
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorField
%

if isnumeric(SO3VF1)
  SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1 .* SO3VF2.eval(rot),SO3VF2.CS,SO3VF2.SS);
  return
end
if isnumeric(SO3VF2)
  SO3VF = SO3VF2 .* SO3VF1;
  return
end

ensureCompatibleSymmetries(SO3VF1,SO3VF2);
SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1.eval(rot) .* SO3VF2.eval(rot),SO3VF1.SRight,SO3VF1.SLeft);

end