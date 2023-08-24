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
  cs = SO3F.CS.rot;
  if length(cs)>2 && ~all(any(rot(:).' == cs(:)))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3F.CS = crystalSymmetry;
  end
else
  ss = SO3F.SS.rot;
  if length(ss)>2 && ~all(any(rot(:).' == ss(:)))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry;
  end
end


for i = 1:length(SO3F.components)
  SO3F.components{i} = SO3F.components{i}.rotate_outer(rot,varargin{:});  
end
