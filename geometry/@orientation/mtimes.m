function r = mtimes(a,b,takeRight)
% orientation times Miller and orientation times orientation
%
% Syntax
%   o = o1 * o2
%   r = o * h
%   h = inv(o) * r
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
end

% ensure inner symmetries coincide
[a, left, right] = ensureSym(a,b);

% orientation times object
if ~isa(b,'quaternion') 
  r = rotate_outer(b,a);
  return 
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
