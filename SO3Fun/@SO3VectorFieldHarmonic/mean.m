function v = mean(SO3VF)
%
% Syntax
%   f = mean(SO3VF)
%
% Output
%   v - @vector3d
%

v = SO3TangentVector(SO3VF.SO3F.fhat(1, :),SO3VF.internTangentSpace);

end
