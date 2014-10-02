function r = times(a,b)
% vec = ori .* Miller
%
% Syntax
%  o = o1 .* o2
%  r = o .* h
%  h = inv(o) .* r
%
% Input
%  o - @orientation
%  h - @Miller indice
%  r - @vector3d
%
% See also

% collect inner and outer symmetries
[left,inner1] = extractSym(a);
[inner2,right] = extractSym(b);

% ensure inner symmetries coincide
if inner1 ~= inner2
  if isa(a,'orientation')
    a = a.transformReferenceFrame(inner2);
  elseif all(isnull(min(angle_outer(inner2,a))))
    left = inner2;
  else
    warning('Rotation does not respect symmetry!');
  end
end

% rotation multiplication
r = times@rotation(a,b);

% convert back to rotation
if isa(right,'crystalSymmetry') || isa(left,'crystalSymmetry')
  if isa(b,'vector3d')
    r = Miller(r,left);
  else
    r = orientation(r,right,left);
  end
end
