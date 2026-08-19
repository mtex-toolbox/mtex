function SO3VF = rdivide(SO3VF1, SO3VF2)
% overloads |SO3VF ./ a|
%
% Syntax
%   SO3VF = SO3VF ./ a
%   SO3VF = SO3VF ./ SO3F
%   
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%

if isnumeric(SO3VF2)
  SO3VF = times(1./SO3VF2,SO3VF1);
  return
end

if ~isa(SO3VF2,'SO3Fun') || ~isscalar(SO3VF2)
  error('In case of SO3VectorFields, it only make sense to divide with a scalar value or a scalar SO3Fun.')
end

% Note that for SO3VF.SO3F = SO3VF1 ./ SO3VF2.SO3F the tangentSpace and
% internTangentSpace of SO3VF2 have to be the same
tS = SO3VF1.tangentSpace;
SO3VF1.tangentSpace = SO3VF1.internTangentSpace;
% Furthermore, dependent on the tangent space representation, we have to ignore one of the symmetries of SO3FunHarmonic 
if sign(SO3VF1.tangentSpace)==1
  SO3VF2.SS = stripSym(SO3VF2.SS);
else
  SO3VF2.CS = stripSym(SO3VF2.CS);
end

% quadrature
SO3VF = rdivide@SO3VectorField(SO3VF1,SO3VF2);
SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3VF1.bandwidth + SO3VF2.bandwidth));
SO3VF.tangentSpace = tS;


end