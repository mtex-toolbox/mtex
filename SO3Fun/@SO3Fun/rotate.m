function SO3F = rotate(SO3F,rot,varargin)
% rotate function on SO(3)
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%
% Input
%  SO3F - @SO3Fun
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunHandle

SO3F = rotate_outer(SO3F,rot,varargin{:});