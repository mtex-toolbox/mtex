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
%  h - @Miller crystal direction
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
[a, frameB, frameA] = ensureSym(a,b);

% consider the cases ori * Miller, ori * tensor, ori * slipSystem
if ~isa(b,'quaternion')
  r = rotate(b,a);
  return
end

% rotation multiplication
% the second argument ensures the result is an orientation again
r = times@rotation(a,b,isa(b,'orientation'));

% a .* b is b.frameA -> a.frameB
r.frameA = frameA;
r.frameB = frameB;

end
