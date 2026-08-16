function SO3F = rotate_outer(SO3F,rot,varargin)
% rotate function on SO(3) by multiple rotations
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%   SO3F = rotate(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3FunComposition
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunComposition
%
% See also
% SO3FunHandle/rotate_outer

if check_option(varargin,'right')
  SO3F.CS = dropSymmetry(SO3F.CS,rot,'crystal','ODF');
else
  SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF');
end

for i = 1:length(SO3F.components)
  SO3F.components{i} = SO3F.components{i}.rotate_outer(rot,varargin{:});  
end
