function r = mtimes(a,b,takeRight)
% orientation times Miller and orientation times orientation
%
% Syntax
%   o = o1 * o2
%   r = o * h
%   h = inv(o)*r
%
% Input
%  o - @orientation
%  h - @Miller indice
%  r - @vector3d
%
% See also
% orientation/times

% this is some shortcut for internal use
if nargin == 3
  r = mtimes@rotation(a,b,takeRight);
  return
end

% special case multiplication with +-1
if isnumeric(a) || isnumeric(b)
  r = mtimes@rotation(a,b);
  return
end

% orientation times symmetry
if isa(b,'symmetry') 

  r = mtimes@quaternion(a,b.rot,0);
  return
  
elseif ~isa(b,'quaternion')  && ~isnumeric(b) % orientation times object
  try
    if ~eq(a.CS,b.CS,'Laue')
      warning('Symmetries %s and %s are different but should be equal',a.CS.pointGroup,b.CS.pointGroup);
    end
  catch
    if isa(a.CS,'crystalSymmetry')
      warning('Possibly applying an orientation to an object in specimen coordinates!')
    end
  end
  r = rotate_outer(b,a);
  return 
end

% collect inner and outer symmetries
[left,inner1] = extractSym(a);
[inner2,right] = extractSym(b);

% ensure inner symmetries coincide
if isempty(inner1)  
  if ~isempty(inner2) && ~isa(inner2,'specimenSymmetry')
    warning('Rotation does not respect symmetry!');
  end
elseif isempty(inner2)
  if ~isempty(inner1) && ~isa(inner1,'specimenSymmetry')
    warning('Rotation does not respect symmetry!');
  end
elseif ~eq(inner1,inner2,'Laue')
  if isa(a,'orientation')
    a = a.transformReferenceFrame(inner2);
  elseif all(isnull(min(angle_outer(inner2,a))))
    left = inner2;
  else
    warning('Rotation does not respect symmetry!');
  end
end

% rotation multiplication
r = mtimes@quaternion(a,b,isa(b,'orientation'));

% convert back to orientation
if isa(right,'crystalSymmetry') || isa(left,'crystalSymmetry')
  r.CS = right;
  r.SS = left;
else % otherwise it is only a rotation anymore
  r = rotation(r);
end

end
