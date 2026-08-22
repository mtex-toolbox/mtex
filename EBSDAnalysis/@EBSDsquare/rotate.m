function ebsd = rotate(ebsd,rot,varargin)
% rotate a gridded EBSD map, keeping its matrix layout canonical
%
% Syntax
%
%   ebsd = rotate(ebsd,10*degree)
%   ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,180*degree))
%   ebsd = rotate(ebsd,180*degree,'keepEuler')
%
% Input
%  ebsd  - @EBSDsquare
%  angle - double
%  rot   - @rotation
%
% Options
%  center - [x,y] center of rotation, default is (0,0)
%
% Flags
%  keepXY    - rotate only the orientation data
%  keepEuler - rotate only the spatial data
%
% Output
%  ebsd - @EBSDsquare
%
% Description
% Rotating the spatial data moves the positions but not the entries of the
% matrix, so the grid directions come out somewhere else than the layout rule
% puts them: <EBSDGrid.html gridify> orients a map so dimension 1 runs along
% the more vertical grid direction and dimension 2 along the more horizontal
% one, both with increasing coordinates. A quarter turn leaves that violated,
% and the map is then a grid whose stored order no longer says what its own
% d1 and d2 say - which defeats the point of the grid classes, whose reason to
% exist is handing a stable matrix to image registration tools.
%
% So the layout is restored here, by reindexing. Nothing is resampled and no
% value is invented: a transpose and two flips are all that is ever applied,
% and only when the rotation actually disturbed the layout. A rotation that
% leaves the grid axis aligned - any multiple of 90 degrees - always lands
% back on the rule exactly. One that does not, say 30 degrees, is put as close
% to it as a permutation can get, which is what gridify itself would do.
%
% NB this changes the SHAPE of the map for a quarter turn: an r x c map comes
% back c x r. That is the honest answer - the sample really did turn - and it
% is what keeps size(ebsd) meaning the same thing before and after.
%
% See also
% EBSD/rotate EBSD/gridify

ebsd = rotate@EBSD(ebsd,rot,varargin{:});

% only the spatial half can disturb the layout
if check_option(varargin,'keepXY'), return; end

ebsd = orientGrid(ebsd);

end

% -------------------------------------------------------------------------
function ebsd = orientGrid(ebsd)
% put the matrix back on the layout rule, by reindexing only
%
% Deliberately the same rule as EBSD/private/squarify/orientGrid, which is
% not reachable from here. Keep the two in step.

d1 = ebsd.pos(2,1) - ebsd.pos(1,1);
d2 = ebsd.pos(1,2) - ebsd.pos(1,1);

% which of the two grid directions is the more horizontal one
horizontal = @(d) abs(dot(d,xvector)) - abs(dot(d,yvector));

lin = reshape(1:numel(ebsd.id),size(ebsd.id));
plain = lin;

if horizontal(d1) > horizontal(d2)
  lin = lin.';
  [d1,d2] = deal(d2,d1);
end

% ensure increasing coordinates along both grid directions
if dot(d1,yvector) < 0, lin = flipud(lin); end
if dot(d2,xvector) < 0, lin = fliplr(lin); end

% subsref explicitly: inside a class method MATLAB indexes the object with
% the built-in rather than the overload, and ebsd(lin) would treat this
% scalar object as a 1x1 array
if ~isequal(lin,plain)
  ebsd = subsref(ebsd,substruct('()',{lin}));
end

end
