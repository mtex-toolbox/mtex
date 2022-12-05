function SO3F = rotate_outer(SO3F,varargin)
% rotate ODF
%
% Syntax
%   SO3F = rotate_outer(SO3F,rot)
%
% Input
%  SO3F - @SO3Fun
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunHandle

SO3F = SO3FunHandle(@(rot) SO3F.eval(rot));

SO3F = rotate_outer(SO3F,varargin{:});