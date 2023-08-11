function SO3VF = rotate(SO3VF,q,varargin)
% rotate a SO3 vector field by one rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%   SO3VF = rotate(SO3VF,rot,'right')
%
% Input
%  SO3VF - @SO3VectorFieldHandle
%  rot   - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHandle
%
% See also
% SO3FunHandle/rotate_outer

if check_option(varargin,'right')
  cs = SO3VF.CS.rot;
  if length(cs)>2 && ~any(q == cs(:))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3VF.CS = crystalSymmetry;
  end
else
  ss = SO3VF.SS.rot;
  if length(ss)>2 && ~any(q == ss(:))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3VF.SS = specimenSymmetry;
  end
end


if check_option(varargin,'right')
  SO3VF.fun = @(r) SO3VF.fun(r* inv(q));
else
  SO3VF.fun = @(r) SO3VF.fun(inv(q) * r);
end
