function SO3F = rotate_outer(SO3F,varargin)
% rotate function on SO(3) by multiple rotations
%
% Syntax
%   SO3F = rotate_outer(SO3F,rot)
%   SO3F = rotate_outer(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3Fun
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunHandle
%
% See also
% SO3FunHandle/rotate_outer

SO3F = SO3FunHandle(@(rot) SO3F.eval(rot),SO3F.CS,SO3F.SS);

SO3F = rotate_outer(SO3F,varargin{:});