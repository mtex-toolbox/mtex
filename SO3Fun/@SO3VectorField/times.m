function SO3VF = times(SO3VF1,SO3VF2)
% overloads |a .* SO3VF|
%
% Syntax
%   SO3VF = a .* SO3VF
%   SO3VF = SO3VF .* a
%   SO3VF = SO3VF .* SO3F;
%   SO3VF = SO3F .* SO3VF;
%
% Input
%  SO3VF - @SO3VectorField
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorField
%


if isnumeric(SO3VF2) || isa(SO3VF2,'SO3Fun')
  SO3VF = SO3VF2 .* SO3VF1;
  return
end

if ~(isnumeric(SO3VF1) || isa(SO3VF1,'SO3Fun')) || ~isscalar(SO3VF1)
  error('In case of SO3VectorFields, it only make sense to scale with a scalar value or a scalar SO3Fun.')
end


% (When there are multiple concatenations, we try to prevent the tangential space from switching back and forth repeatedly.)
if isnumeric(SO3VF1)
  tS = SO3VF2.tangentSpace;
  tS_I = SO3VF2.internTangentSpace;
  SO3VF2.tangentSpace = tS_I; 
  SO3VF = SO3VectorFieldHandle(@(rot) SO3VF1 .* SO3VF2.eval(rot),SO3VF2.hiddenCS,SO3VF2.hiddenSS,SO3VF2.internTangentSpace);
  SO3VF.tangentSpace = tS;
  return
end

fun = @(rot) SO3VF1.eval(rot) .* SO3VF2.eval(rot);
SO3VF = SO3VectorFieldHandle(fun,SO3VF2.hiddenCS,SO3VF2.hiddenSS,SO3VF2.tangentSpace);

end