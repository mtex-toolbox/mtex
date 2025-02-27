function SO3VF = rdivide(SO3VF1, SO3VF2)
% overloads |SO3VF1 ./ SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 ./ SO3VF2
%   SO3VF = SO3VF1 ./ a
%   SO3VF = a ./ SO3VF2
%   SO3VF = SO3F .* SO3VF1
%   SO3VF = SO3VF1 .* SO3F
%   
% Input
%  SO3VF1, SO3VF2 - @SO3VectorFieldRBF
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorFieldRBF
%


if isnumeric(SO3VF1) || isa(SO3VF1,'vector3d')
  ensureCompatibleTangentSpaces(SO3VF1,SO3VF2);
  SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1 ./ SO3VF2.eval(rot),SO3VF2.SRight,SO3VF2.SLeft,SO3VF2.tangentSpace);
  SO3VF = SO3VectorFieldRBF(SO3VF);
  return
end

if isnumeric(SO3VF2) || isa(SO3VF2,'vector3d')
  SO3VF = times(SO3VF1,1./SO3VF2);
  return
end

ensureCompatibleSymmetries(SO3VF1,SO3VF2);
SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1.eval(rot)./ SO3VF2.eval(rot),SO3VF1.SRight,SO3VF1.SLeft,SO3VF1.tangentSpace);
SO3VF = SO3VectorFieldRBF(SO3VF);

end