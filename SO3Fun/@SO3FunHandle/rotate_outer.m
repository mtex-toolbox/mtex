function SO3F = rotate_outer(SO3F, rot, varargin)
% rotate function on SO(3) by multiple rotations
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
%  SO3F - @SO3FunHandle
%  rot  - @rotation, @orientation
%
% Output
%  SO3F - @SO3FunHandle
%

if check_option(varargin,'right')
  if isa(rot,'orientation')
    assert(rot.SS == SO3F.CS,'symmetry missmatch');
    SO3F.CS = rot.CS;
  elseif numSym(SO3F.CS.Laue)>2 && ~all(any(rot(:).' == SO3F.CS.rot(:)))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3F.CS = crystalSymmetry;
  end

  SO3F.fun = @(r) SO3F.fun(r * inv(rot)); %#ok<MINV>
else
  if isa(rot,'orientation')
    assert(rot.CS == SO3F.SS,'symmetry missmatch')
    SO3F.SS = rot.SS;
  elseif numSym(SO3F.SS.Laue)>2 && ~any(rot == SO3F.SS.rot(:))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry;
  end

  SO3F.fun = @(r) SO3F.fun((inv(rot) * r).');  %#ok<MINV>
end

end