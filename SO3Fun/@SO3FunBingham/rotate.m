function SO3F = rotate(SO3F,rot,varargin)
% rotate function on SO(3) by a rotation
%
% Syntax
%
%   % rotate in specimen coordinates
%   SO3F = rotate(SO3F,rot)
%
%   % rotate in crystal coordinates, e.g. for phase transformation
%   % or reference frame transformation 
%   SO3F = rotate(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3FunBingham
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunBingham
%
% See also
% SO3FunHandle/rotate_outer
    
if check_option(varargin,'right')
  if isa(rot,'orientation')
    assert(rot.SS == SO3F.CS,'symmetry missmatch')    
  elseif numSym(SO3F.CS.Laue)>2 && ~all(any(rot(:).' == SO3F.CS.rot(:)))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3F.CS = crystalSymmetry;
  end

  SO3F.A = orientation(SO3F.A * rot);
else
  if isa(rot,'orientation')
    assert(rot.CS == SO3F.SS,'symmetry missmatch')    
  elseif numSym(SO3F.SS.Laue)>2 && ~any(rot == SO3F.SS.rot(:))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry;
  end

  SO3F.A = orientation(rot * SO3F.A);
end
