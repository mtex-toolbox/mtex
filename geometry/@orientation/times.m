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
if inner1 ~= inner2, warning('MTEX:Orientation','Possible missmatch in symmetry!');end

% rotation multiplication
r = times@rotation(a,b);

% convert back to rotation
if isCS(right) || isCS(left)
  if isa(b,'vector3d')
    r = Miller(r,left);
  else
    r = orientation(r,right,left);
  end
end
