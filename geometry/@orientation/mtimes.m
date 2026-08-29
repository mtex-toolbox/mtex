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
%  h - @Miller indices
%  r - @vector3d
%
% See also
% orientation/times

% this is some shortcut for internal use
if nargin == 3
  r = mtimes@rotation(a,b,takeRight);
  return
end

% orientation times object
if isnumeric(a) || isnumeric(b)
  % special case multiplication with +-1
  r = mtimes@rotation(a,b);
  return
elseif isa(b,'referenceFrame') 
  % orientation times symmetry
  r = mtimes@quaternion(a,b.rot,0);
  return
elseif ~isa(b,'quaternion') 
  r = rotate_outer(b,a);
  return 
end

% ensure inner symmetries coincide
[a, frameB, frameA] = ensureSym(a,b);

% rotation multiplication
% the second argument ensures the result is an orientation again
r = mtimes@quaternion(a,b,isa(b,'orientation'));

% a .* b is b.frameA -> a.frameB
r.frameA = frameA;
r.frameB = frameB;

end
