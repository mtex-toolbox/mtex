function SO3VF = uminus(SO3VF)
% negate a vector field on SO(3)
%
% Syntax
%
%   SO3VF = -SO3VF % the vector field pointing in the opposite direction
%

SO3VF.SO3F = -SO3VF.SO3F;

end
