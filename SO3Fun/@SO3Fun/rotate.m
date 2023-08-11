function SO3F = rotate(SO3F,rot,varargin)
% rotate function on SO(3) by a rotation
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%   SO3F = rotate(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3Fun
%  rot  - @rotation
%
% Output
%  SO3F - @SO3Fun
%
% See also
% SO3FunHandle/rotate_outer


SO3F = rotate_outer(SO3F,rot,varargin{:});
