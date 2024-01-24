function SO3F = rotate_outer(SO3F, q, varargin)
% rotate function on SO(3) by multiple rotations
%
% Syntax
%   SO3F = rotate_outer(SO3F,rot)
%   SO3F = rotate_outer(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3FunHandle
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunHandle
%


if check_option(varargin,'right')
  cs = SO3F.CS.rot;
  if length(cs)>2 && ~all(any(q(:).' == cs(:)))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3F.CS = crystalSymmetry;
  end
else
  ss = SO3F.SS.rot;
  if length(ss)>2 && ~all(any(q(:).' == ss(:)))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry;
  end
end


if check_option(varargin,'right')
  SO3F.fun = @(r) SO3F.fun(r * inv(q));
else
  SO3F.fun = @(r) SO3F.fun((inv(q) * r).');
end

end