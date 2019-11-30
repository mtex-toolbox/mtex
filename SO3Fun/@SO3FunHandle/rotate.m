function SO3F = rotate(SO3F, rot, varargin)
% rotate a function by a rotation
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%
% Input
%  SO3F - @SO3FunHandle
%  rot  - @rotation
%
% Output 
%  SO3F - @SO3FunHandle
%

SO3F = SO3F.rotate_outer(rot,varargin{:});

end
