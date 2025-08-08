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

% Note that for SO3VF.SO3F = SO3VF1 ./ SO3VF2.SO3F the tangentSpace and
% internTangentSpace of SO3VF2 have to be the same
SO3VF = rdivide@SO3VectorField(SO3VF1,SO3VF2);

SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3VF1.bandwidth + SO3VF2.bandwidth));

end