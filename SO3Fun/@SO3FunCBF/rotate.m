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
%  SO3F - @SO3FunCBF
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunCBF
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

  for k = 1:length(SO3F)
    newH{k} = unique(inv(rot) .* SO3F.h.symmetrise('unique'));
  end
  numH(k) = cellfun(@numel,newH);
  SO3F.h = vertcat(newH{:});
  SO3F.r = repelem(SO3F.r,numH,1);  
  SO3F.weights = repelem(SO3F.weights ./ numH,numH,1);
 
else
  if isa(rot,'orientation')
    assert(rot.CS == SO3F.SS,'symmetry missmatch')    
  elseif numSym(SO3F.SS.Laue)>2 && ~any(rot == SO3F.SS.rot(:))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry.default;
  end

  SO3F.r = rot * SO3F.r;
end
    
end
