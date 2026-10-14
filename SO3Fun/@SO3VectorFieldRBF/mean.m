function v = mean(SO3VF)
% mean value of a vector field on SO(3)
%
% Syntax
%
%   v = mean(SO3VF)   % the mean of the field over the rotation group
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  v - @vector3d
%

v = vector3d(mean(SO3VF.SO3F));

end
