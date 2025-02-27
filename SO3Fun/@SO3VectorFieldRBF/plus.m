function SO3VF = plus(SO3VF1, SO3VF2)
% overloads |SO3VF1 + SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 + SO3VF2
%   SO3VF = a + SO3VF1
%   SO3VF = SO3VF1 + a
%   SO3VF = SO3VF1 + SO3F;
%   SO3VF = SO3F + SO3VF2;
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorFieldRBF
%

if isa(SO3VF1,'vector3d')
  ensureCompatibleTangentSpaces(SO3VF1,SO3VF2);
  SO3VF1 = SO3VF1.xyz.';
end
if isnumeric(SO3VF1) || isa(SO3VF1,'SO3Fun')
  SO3VF = SO3VF2;
  SO3VF.SO3F = SO3VF1 + SO3VF2.SO3F;
  return
end

if isnumeric(SO3VF2) || isa(SO3VF2,'vector3d') || isa(SO3VF2,'SO3Fun')
  SO3VF = SO3VF2 + SO3VF1;
  return
end

ensureCompatibleSymmetries(SO3VF1,SO3VF2)
SO3VF1 = SO3VectorFieldRBF(SO3VF1);
SO3VF2 = SO3VectorFieldRBF(SO3VF2);
SO3VF = SO3VF1;
SO3VF.SO3F = SO3VF1.SO3F+SO3VF2.SO3F;

end
