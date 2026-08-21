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

% 3. compute from scratch - always run as the baseline, also when there is a hint
xyz = ebsd.pos.xyz;
uc = calcUnitCell(xyz,varargin{:});

hint = get_option(varargin,'hint');

% a grid the user asked for is not a measurement, so do not test a hint against it
if check_option(varargin,{'GridResolution','GridType','GridRotation'})
  hint = [];
end

if ~isempty(hint)
  % 2. prefer the hint unless the estimate is well-defined and disagrees with it -
  % well-defined is a property of the positions, not of the cell that comes out
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
    % a different cell shape is no disagreement, a vendor states a rectangular step
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
