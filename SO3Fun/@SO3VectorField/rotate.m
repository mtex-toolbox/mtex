function SO3VF = rotate(SO3VF,rot,varargin)
% rotate a SO3 vector field by a rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%
% Input
%  SO3VF - @SO3VectorField
%  rot  - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHandle
%

SO3VF = SO3VectorFieldHandle(@(q) SO3VF.eval(inv(rot)*q),SO3VF.CS,SO3VF.SS);
