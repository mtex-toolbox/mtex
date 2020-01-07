function v = mean(SO3VF)
%
% Syntax
%   f = mean(SO3VF)
%
% Output
%   v - @vector3d
%

v = vector3d(SO3VF.SO3F.fhat(1, :));

end
