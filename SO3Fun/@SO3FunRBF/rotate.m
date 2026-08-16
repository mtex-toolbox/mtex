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
%  SO3F - @SO3FunRBF
%  rot  - @rotation, @orientation
%
% Output
%  SO3F - @SO3FunRBF
%
% See also
% SO3FunHandle/rotate_outer
    
if check_option(varargin,'right')

  if isa(rot,'orientation')
    assert(rot.SS == SO3F.CS,'symmetry missmatch')    
  else
  SO3F.CS = dropSymmetry(SO3F.CS,rot,'crystal','ODF');
  end

  SO3F.center = orientation(SO3F.center * rot);
else
  if isa(rot,'orientation')
    assert(rot.CS == SO3F.SS,'symmetry missmatch')    
  else
  SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF');
  end

  SO3F.center = orientation(rot * SO3F.center);
end

end
