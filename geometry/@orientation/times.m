function r = times(a,b,takeRight)
% vec = ori .* Miller
%
% Syntax
%   o = o1 .* o2
%   r = o .* h
%   h = inv(o) .* r
%
% Input
%  o - @orientation
%  h - @Miller indice
%  r - @vector3d
%
% See also

if nargin == 3
  r = times@rotation(a,b,takeRight);
  return
end

% special case multiplication with +-1
if isnumeric(a) || isnumeric(b)
  r = times@rotation(a,b);
  return
end
 
% collect inner and outer symmetries
[left,inner1] = extractSym(a);
[inner2,right] = extractSym(b);

% ensure inner symmetries coincide
if isempty(inner1)  
  if ~isempty(inner2) 
    if ~isa(inner2,'specimenSymmetry') || ...
        (inner2.id > 2 && any(max(dot_outer(inner2.rot,a))<0.99))
      warning('Rotation does not respect symmetry!');
    end
  end
elseif isempty(inner2)
  if ~isempty(inner1) && ~isa(inner1,'specimenSymmetry')
    warning('Rotation does not respect symmetry!');
  end
elseif ~eq(inner1,inner2,'Laue')
  if isa(inner2,'specimenSymmetry') && isa(inner1,'specimenSymmetry')
  elseif isa(a,'orientation')
    a = a.transformReferenceFrame(inner2);
  elseif all(isnull(min(angle_outer(inner2,a))))
    left = inner2;
  else
    warning('Rotation does not respect symmetry!');
  end
end

% consider the cases ori * Miller, ori * tensor, ori * slipSystem
if ~isa(b,'quaternion') && ~isnumeric(b)
  r = rotate(b,a);
  return
end

% rotation multiplication
r = times@rotation(a,b,isa(b,'orientation'));

% convert back to orientation
if isa(right,'crystalSymmetry') || isa(left,'crystalSymmetry')

  r.CS = right;
  r.SS = left;

else % otherwise it is only a rotation

  r = rotation(r);

end

end
