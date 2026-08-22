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
% EBSD/rotate EBSD/gridify EBSDsquare/transformReferenceFrame

ebsd = rotate@EBSD(ebsd,rot,varargin{:});

% only the spatial half can disturb the layout
if check_option(varargin,'keepXY'), return; end

ebsd = transformReferenceFrame(ebsd,gridLayout());

end
