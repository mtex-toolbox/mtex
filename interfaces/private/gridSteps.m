function [xStep,yStep] = gridSteps(g,fmt)
% the grid spacings along x and y, or refuse
%
% Description
%
% The .ang and .ctf headers state one spacing along x and one along y.
% Those exist only while the grid is aligned with those axes - a rotated
% map has a step along neither, and writing its two lattice spacings into
% those fields would claim a grid the file does not describe. Since
% @EBSDhex and @EBSDsquare can both carry a rotated grid, say so instead.
%
% Syntax
%   [xStep,yStep] = gridSteps(ebsdGrid,'ang')
%
% Input
%  g   - gridded @EBSD, i.e. @EBSDsquare or @EBSDhex
%  fmt - 'ang' or 'ctf', names the caller in the error message
%
% Output
%  xStep, yStep - grid spacing along x and y

if nargin < 2, fmt = 'ang'; end

if isa(g,'EBSDhex')
  % the hex row step is at 60 degree even on an unrotated map, so the test
  % has to be on the dense direction and the one across it, not on the raw
  % matrix steps. The cross vector spans two lines, hence the halving.
  if g.isRowAlignment
    u = g.pos(1,2) - g.pos(1,1);  v = (g.pos(3,1) - g.pos(1,1)) ./ 2;
  else
    u = g.pos(2,1) - g.pos(1,1);  v = (g.pos(1,3) - g.pos(1,1)) ./ 2;
  end
else
  u = g.pos(1,2) - g.pos(1,1);  v = g.pos(2,1) - g.pos(1,1);
end

onAxis = @(d) max(abs(dot(normalize(d),[xvector yvector]))) > 1 - 1e-6;

if ~(onAxis(u) && onAxis(v))
  error(['MTEX:export_' fmt ':notAxisAligned'], ...
    ['This grid is rotated with respect to the x/y axes (its spacings run '...
    'along %.1f and %.1f degree), and the %s format has no way to say so: '...
    'its header carries one step along x and one along y.\n\n'...
    'Rotate the map back before exporting, e.g.\n'...
    '  ebsd = rotate(ebsd,-omega);\n'...
    'or export a format that stores the positions themselves.'], ...
    atan2(u.y,u.x)/degree, atan2(v.y,v.x)/degree, fmt);
end

% which of the two runs along x. Read off the grid rather than taken from
% g.dx/dy - @EBSDsquare has had no dx/dy since 859b62af0, so ang export of a
% square map died in the header with "Unrecognized method, property, or
% field 'dx'".
if abs(dot(normalize(u),xvector)) > 1 - 1e-6
  xStep = norm(u); yStep = norm(v);
else
  xStep = norm(v); yStep = norm(u);
end

end
