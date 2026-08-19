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
%  SO3VF - @SO3VectorFieldHarmonic
%  a - double
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
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

% Note that for SO3VF.SO3F = SO3VF1 .* SO3VF2.SO3F the tangentSpace and
% internTangentSpace of SO3VF2 have to be the same
tS = SO3VF2.tangentSpace;
SO3VF2.tangentSpace = SO3VF2.internTangentSpace;
% Furthermore, dependent on the tangent space representation, we have to ignore one of the symmetries of SO3FunHarmonic 
if sign(SO3VF2.tangentSpace)==1
  SO3VF1.SS = stripSym(SO3VF1.SS);
else
  SO3VF1.CS = stripSym(SO3VF1.CS);
end

% quadrature
SO3VF = times@SO3VectorField(SO3VF1,SO3VF2);
SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3VF1.bandwidth + SO3VF2.bandwidth));
SO3VF.tangentSpace = tS;

end