function [xStep,yStep] = gridSteps(g)
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
%   [xStep,yStep] = gridSteps(ebsdGrid)
%
% Input
%  g - gridded @EBSD, i.e. @EBSDsquare or @EBSDhex
%
% Output
%  xStep, yStep - grid spacing along x and y

if isa(g,'EBSDhex')
  % test the dense direction and the one across it, the cross vector spans two lines
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
  error('MTEX:export:notAxisAligned', ...
    ['This grid is rotated with respect to the x/y axes (its spacings run '...
    'along %.1f and %.1f degree), and the file has no way to say so: '...
    'its header carries one step along x and one along y.\n\n'...
    'Rotate the map back before exporting, e.g.\n'...
    '  ebsd = rotate(ebsd,-omega);'], ...
    atan2(u.y,u.x)/degree, atan2(v.y,v.x)/degree);
end

% which of the two runs along x, read off the grid - there is no g.dx/dy any more
if abs(dot(normalize(u),xvector)) > 1 - 1e-6
  xStep = norm(u); yStep = norm(v);
else
  xStep = norm(v); yStep = norm(u);
end

end
