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
  else
  SO3F.CS = dropSymmetry(SO3F.CS,rot,'crystal','ODF');
  end

  SO3F.fun = @(r) SO3F.fun(r * inv(rot)); %#ok<MINV>
else
  if isa(rot,'orientation')
    assert(rot.CS == SO3F.SS,'symmetry missmatch')
    SO3F.SS = rot.SS;
  else
  SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF');
  end

  SO3F.fun = @(r) SO3F.fun((inv(rot) * r).');  %#ok<MINV>
end

end