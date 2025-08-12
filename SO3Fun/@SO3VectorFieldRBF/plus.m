function SO3VF = plus(SO3VF1, SO3VF2)
% overloads |SO3VF1 + SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 + SO3VF2
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField
%

if ~isa(SO3VF1,'SO3VectorField') || ~isa(SO3VF2,'SO3VectorField')
  error('In case of SO3VectorFields, it only make sense to sum with other SO3VectorFields.')
end


% ensure compatible symmetries
em = (SO3VF1.hiddenCS ~= SO3VF2.hiddenCS) || (SO3VF1.hiddenSS ~= SO3VF2.hiddenSS);
if em
  error('The symmetries are not compatible. (Calculations with @SO3VectorField''s needs suitable intern symmetries.)')
end


% symmetries and tangent spaces have to coincide
if isa(SO3VF1,'SO3VectorFieldRBF') && isa(SO3VF2,'SO3VectorFieldRBF') && sign(SO3VF1.internTangentSpace) == sign(SO3VF2.internTangentSpace)
  fun = SO3VF1.SO3F + SO3VF2.SO3F;
  % Note that if the SO3FunRBF's do not match, we may obtain a SO3FunHandle
  if isa(fun,'SO3FunRBF')
    SO3VF = SO3VF1;
    SO3VF.SO3F = fun;
    return
  end
end

SO3VF = plus@SO3VectorField(SO3VF1,SO3VF2);

end