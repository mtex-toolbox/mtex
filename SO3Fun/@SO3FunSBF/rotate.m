function SO3F = rotate(SO3F,rot,varargin)
% rotate function on SO(3) by a rotation
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%
% Input
%  SO3F - @SO3FunSBF
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunSBF
%
% See also
% SO3FunHandle/rotate_outer
    
  SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF');

if check_option(varargin,'right')
  error('Not implemented yet.')
else
  SO3F.E = rotate(SO3F.E,rot);
end

    
end
