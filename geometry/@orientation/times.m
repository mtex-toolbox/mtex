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
 
% ensure inner symmetries coincide
[a, left, right] = ensureSym(a,b);

% consider the cases ori * Miller, ori * tensor, ori * slipSystem
if ~isa(b,'quaternion')
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
