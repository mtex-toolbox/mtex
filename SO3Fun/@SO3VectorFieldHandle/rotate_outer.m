function SO3VF = rotate_outer(SO3VF, rot)
% rotate a function by a rotation
%
% Syntax
%   SO3F = SO3F.rotate_outer(rot)
%
% Input
%  SO3F - @SO3VectorFieldHandle
%  rot - @rotation
%
% Output 
%  SO3F - @SO3VectorFieldHandle
%

SO3VF.fun = @(v) SO3VF.fun(inv(rot)*v);

end
