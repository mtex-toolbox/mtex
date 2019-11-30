function SO3F = rotate_outer(SO3F, rot, varargin)
% rotate a function by a rotation
%
% Syntax
%   SO3F = SO3F.rotate_outer(rot)
%
% Input
%  SO3F - @SO3FunHandle
%  rot  - @rotation
%
% Output 
%  SO3F - @SO3FunHandle
%

if check_option(varargin,'right')
  SO3F.fun = @(pos) SO3F.fun(pos * inv(rot));
else
  SO3F.fun = @(pos) SO3F.fun(inv(rot) * pos);
end

end
