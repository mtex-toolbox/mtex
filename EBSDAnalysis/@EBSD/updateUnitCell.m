function ebsd = updateUnitCell(ebsd,uc,varargin)
% this function should be called after the spatial coordinates of an EBSD
% data set have been modified
%
% Options
%  hint - a candidate unit cell (e.g. derived from a file's own header
%         step size). calcUnitCell's statistical position-based estimate
%         is always computed as the baseline/fallback; the hint is
%         preferred over it whenever the estimate cannot contradict it -
%         either because there were no positions for calcUnitCell to
%         estimate from at all, or because it agrees with the hint.
%         Anything else keeps the estimate and warns: positions and unit
%         cell describing different things is worse than an unscaled map,
%         because nothing downstream can tell.
%
% All remaining options are passed on to calcUnitCell, so that the grid
% options GridResolution, GridType and GridRotation reach it from
% EBSD.load. Any of them makes the cell a requested one rather than a
% measured one, and a hint is then ignored.
%
% See also
% calcUnitCell

if nargin > 1 && ~isempty(uc)
  % 1. an explicit unit cell always wins, no further checks
  ebsd = setUnitCell(ebsd,uc);
  return
end

% 3. compute from scratch - always run as the baseline/fallback, since
% comparing a hint against a cheap independent re-estimate risks subtly
% diverging from calcUnitCell's own (more elaborate) internal logic
xyz = ebsd.pos.xyz;
uc = calcUnitCell(xyz,varargin{:});

hint = get_option(varargin,'hint');

% a grid the user has asked for is not a measurement, so a header hint
% must neither override it nor be tested against it - the test would
% compare the file's step size against the requested one and warn about a
% mismatch that is the whole point of passing the option
if check_option(varargin,{'GridResolution','GridType','GridRotation'})
  hint = [];
end

if ~isempty(hint)
  % 2. prefer the hint unless the estimate is well-defined and actively
  % disagrees with it
  %
  % "well-defined" is a property of the POSITIONS, not of the cell that
  % comes out of them. calcUnitCell falls back to a fixed size-1 square
  % only when it has nothing to work from - which is when the points have
  % no extent - and a size-1 square is otherwise a perfectly ordinary
  % answer. Testing for the value instead was how a Bruker map came to
  % carry positions and a unit cell in different units: its positions
  % were beam column/row indices, so the estimate was a correct square of
  % side 1, read as "no estimate", and the micrometre step size from the
  % header was taken over it. The map then claimed an extent of 1999 x
  % 1331 um for a 778 x 510 um scan and gridify built a lattice 6.7 times
  % too large, 85% of it empty - a 65 second import.
  span = max(xyz(:,1:2),[],1) - min(xyz(:,1:2),[],1);
  noEstimate = isempty(uc) || ~all(isfinite(span)) || all(span == 0);

  if noEstimate
    uc = hint;
  else
    dEst  = stepOf(uc);
    dHint = stepOf(hint);

    if dEst > 0 && abs(dEst - dHint) / dEst > 0.05

      % the two really do describe different lattices - say so, and keep
      % the one that was measured rather than the one that was declared
      warning('MTEX:unitCellMismatch', ...
        ['the header step size does not match the measured pixel spacing ' ...
        '(header: %.4g, estimated: %.4g); keeping the position-based unit cell.'], ...
        dHint, dEst);

    elseif size(uc,1) == length(hint)

      % same lattice, same cell shape - prefer the header's exact numbers
      % over the estimate's fitted ones
      uc = hint;

    end
    % same step but a different cell shape is neither a disagreement nor
    % a reason to take the hint: a vendor states a rectangular step size
    % whatever the lattice, while the estimate knows a hex grid when it
    % sees one. Taking the rectangle there turned an EBSDhex into an
    % EBSDsquare.
  end
end

ebsd = setUnitCell(ebsd,uc);

end

function d = stepOf(uc)
% the lattice step a unit cell describes: the distance to the nearest
% neighbour, which is twice the distance from the cell centre to the
% nearest edge midpoint - the unit cell being the Voronoi cell of the
% lattice (the same reading calcMesh's lattice basis uses).
%
% Comparing mean(norm(uc)) instead compares incompatible shape metrics
% the moment the two cells are not the same polygon, which they routinely
% are not: a vendor's step size arrives as a rectangle while the
% position-based estimate of a hex grid is a hexagon. For a step of 1
% those read 0.7071 and 0.5774, a 22% "mismatch" out of pure convention -
% every hex .ctf warned and threw its header step size away for it.

if ~isa(uc,'vector3d'), uc = vector3d(uc(:,1),uc(:,2),0); end
uc = uc(:);
if isempty(uc), d = 0; return, end

mid = (uc + uc([2:end 1])) / 2;
d = 2 * min(norm(mid));

end

function ebsd = setUnitCell(ebsd,uc)

if isempty(uc)
  uc = vector3d;
elseif ~isa(uc,'vector3d')
  uc = vector3d(uc(:,1),uc(:,2),0);
end

ebsd.unitCell = uc;

end
