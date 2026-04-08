function SO3VF = rdivide(SO3VF1, SO3VF2)
% overloads |SO3VF ./ a|
%
% Syntax
%   SO3VF = SO3VF ./ a
%   SO3VF = SO3VF ./ SO3F
%
% Input
%  SO3VF - @SO3VectorField
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorField
%

% In case of SO3VectorFieldRBF do multiplication
if isnumeric(SO3VF2)
  SO3VF = times(1./SO3VF2,SO3VF1);
  return
end

if ~isa(SO3VF2,'SO3Fun') || ~isscalar(SO3VF2)
  error('In case of SO3VectorFields, it only make sense to divide with a scalar value or a scalar SO3Fun.')
end

fun = @(rot) SO3VF1.eval(rot) ./ SO3VF2.eval(rot);
SO3VF = SO3VectorFieldHandle(fun,SO3VF2.hiddenCS,SO3VF2.hiddenSS,SO3VF2.tangentSpace);

end
