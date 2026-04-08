function SO3VF = rotate(SO3VF,varargin)
% rotate a SO3 vector field by one rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%   SO3VF = rotate(SO3VF,rot,'right')
%
% Input
%  SO3VF - @SO3VectorField
%  rot   - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHandle
%
% See also
% SO3VectorFieldHandle/rotate

SO3VF = SO3VectorFieldHandle(SO3VF);

SO3VF = rotate(SO3VF,varargin{:});