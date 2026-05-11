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
%  SO3VF - @SO3VectorFieldHarmonic
%

if ~isa(SO3VF1,'SO3VectorField') || ~isa(SO3VF2,'SO3VectorField')
  error('In case of SO3VectorFields, it only make sense to sum with other SO3VectorFields.')
end


ensureCompatibleSymmetries(SO3VF1,SO3VF2)


% get tangent space and make compatible
tS = SO3VF1.tangentSpace;
tS_I = SO3VF1.internTangentSpace;
SO3VF1.tangentSpace = tS_I;
SO3VF2.tangentSpace = tS_I;

% transform to vector fields and maybe change internTangentSpace to tangentSpace
SO3VF1 = SO3VectorFieldHarmonic(SO3VF1);
SO3VF2 = SO3VectorFieldHarmonic(SO3VF2);

% summation of compatible Vector Fields
SO3VF = SO3VF1;
SO3VF.SO3F = SO3VF1.SO3F + SO3VF2.SO3F;
SO3VF.tangentSpace = tS;

end