function v = mean(SO3VF)
%
% Syntax
%   f = mean(SO3VF)
%
% Output
%   v - @vector3d
%

v = SO3TangentVector(mean(SO3VF.SO3F),SO3VF.internTangentSpace);

end
