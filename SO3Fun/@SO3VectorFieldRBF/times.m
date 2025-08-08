function SO3VF = times(SO3VF1,SO3VF2)
% overloads |a .* SO3VF|
%
% Syntax
%   SO3VF = a .* SO3VF
%   SO3VF = SO3VF .* a
%   SO3VF = SO3F .* SO3VF
%   SO3VF = SO3VF .* SO3F
%   
% Input
%  SO3VF - @SO3VectorFieldRBF
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


if isnumeric(SO3VF1)
  SO3VF = SO3VF2;
  SO3VF.SO3F = SO3VF1 .* SO3VF2.SO3F;
  return
end

SO3VF = times@SO3VectorField(SO3VF1,SO3VF2);


end