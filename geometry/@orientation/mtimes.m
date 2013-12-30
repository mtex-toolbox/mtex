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

% orientation times vector
if isa(a,'orientation') && isa(b,'vector3d')    
  r = rotate(b,a);
  return 
end

% collect inner and outer symmetries
[left,inner1] = extractSym(a);
[inner2,right] = extractSym(b);

% ensure inner symmetries coincide
if inner1 ~= inner2, warning('MTEX:Orientation','Possible symmetry missmatch!');end

% rotation multiplication
r = mtimes@rotation(a,b);

% convert back to rotation
if isCS(right) || isCS(left), r = orientation(r,right,left); end

% TODO!!!
%if length(r.CS) > 1 && ...
%    ~all(any(isappr(abs(dot_outer(b * r.CS * b^-1,r.CS)),1)))
    
end
