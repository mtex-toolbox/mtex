function SO3VF = times(SO3VF1,SO3VF2)
% overloads |SO3VF1 .* SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 .* SO3VF2
%   SO3VF = a .* SO3VF1
%   SO3VF = SO3VF1 .* a
%   SO3VF = SO3VF1 .* SO3F;
%   SO3VF = SO3F .* SO3VF2;
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorField
%

if isnumeric(SO3VF1)
  SO3VF = SO3VF2 .* SO3VF1;
  return
end
if isnumeric(SO3VF2) || isa(SO3VF2,'vector3d')
  SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1.eval(rot) .* SO3VF2 ,SO3VF1.CS,SO3VF1.SS);
  return
end

ensureCompatibleSymmetries(SO3VF1,SO3VF2);
SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1.eval(rot) .* SO3VF2.eval(rot),SO3VF1.SRight,SO3VF1.SLeft);

end