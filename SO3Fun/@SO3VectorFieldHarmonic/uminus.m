function SO3VF = uminus(SO3VF)
% the negative of a vector field on SO(3)
%
% Syntax
%
%   SO3VF = -SO3VF
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic

SO3VF.SO3F = -SO3VF.SO3F;

end
