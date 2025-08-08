function SO3F = dot(SO3VF1, SO3VF2, varargin)
% pointwise inner product
%
% Syntax
%   SO3F = dot(SO3VF1, SO3VF2)
%
% Input
%   SO3VF1, SO3VF2 - @SO3VectorField
%
% Output
%   SO3F - @SO3FunHarmonic
%

% Note that for SO3VF.SO3F = dot(SO3VF1.SO3F,SO3VF2.SO3F) the tangentSpaces 
% and internTangentSpaces have to be the same and we need to now that both
% are harmonic vector fields
SO3F = dot@SO3VectorField(SO3VF1,SO3VF2);

bw = min(getMTEXpref('maxSO3Bandwidth'),SO3VF1.bandwidth + SO3VF2.bandwidth);
SO3F = SO3FunHarmonic(SO3F,'bandwidth', bw, varargin{:});

end