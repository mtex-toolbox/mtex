function r = mtimes(a,b)
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

% special case multiplication with +-1
if isnumeric(a) || isnumeric(b)
  r = mtimes@rotation(a,b);
  return
end

% orientation times vector
if isa(a,'orientation') && ~isa(b,'quaternion')  && ~isnumeric(b)
  r = rotate_outer(b,a);
  return 
end

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
r = mtimes@rotation(a,b);

% convert back to orientation
if isa(right,'crystalSymmetry') || isa(left,'crystalSymmetry')
  r = orientation(r,right,left); 
end

% TODO!!!
%if length(r.CS) > 1 && ...
%    ~all(any(isappr(abs(dot_outer(b * r.CS * b^-1,r.CS)),1)))
    
end
