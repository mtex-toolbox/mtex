function [v,faces] = generateUnitCells(pos,unitCell,varargin)
% generate a list of patches according to spatial coordinates and the unitCell
%
% Input
%  pos      - midpoints of the cells (vector3d)
%  unitCell - spatial coordinates of the unit cell corners (vector3d)
%
% Output
%  v     - list of vertices (nV x 3)
%  faces - list of faces (numel(pos) x length(unitCell))
%
% Shared corners between neighbouring cells are welded so that patch draws
% each cell once with no doubled edges. Welding is topological: each corner is
% keyed by the pixel's integer grid index plus the corner's fixed half/third
% step, so corners that SHOULD coincide are merged even on a deformed grid
% (where their drifted positions would not match). This replaces the previous
% tolerance-based unique over all corners, which was the runtime bottleneck.
% The (possibly deformed) corner positions are kept as coordinates; a welded
% vertex is placed at the mean of the corners merged into it, so adjacent
% patches meet without gaps.

nC = numel(unitCell);
N  = numel(pos);

% corner positions (deformed positions are used only for coordinates)
cx = pos.x(:) + unitCell.x(:).';       % N x nC
cy = pos.y(:) + unitCell.y(:).';
cz = pos.z(:) + unitCell.z(:).';

% Fast path: skip welding AND pre-triangulate. Shared corners are only needed
% to avoid doubled edges (patch with EdgeColor other than 'none'), to avoid
% double blending under per-face transparency, and to close gaps on deformed
% grids. When none of those apply (opaque, edgeless map - the common case) each
% cell keeps its own corners.
%
% Crucially we also return TRIANGLE faces rather than nC-gon faces: MATLAB's
% patch tessellates every polygon face with a general (concave-capable)
% tessellator on the CPU, which for a million hexagons costs tens of seconds at
% draw time. A convex cell fans into nC-2 triangles from corner 1 (2 for a
% square, 4 for a hex); handing patch triangles skips the tessellator and lets
% the GPU draw the map in a fraction of the time. Triangulation is only valid
% here because there are no edges to draw (fan diagonals would show otherwise).
if check_option(varargin,'noWeld') && ~check_option(varargin,'unitCell')
  v = [cx(:), cy(:), cz(:)];                  % all corners, no merge

  % column c of the corner arrays occupies rows (c-1)*N+(1:N) in v
  col = @(c) ((c-1)*N + (1:N)).';             % vertex ids of corner c, N x 1
  nT  = nC - 2;                               % triangles per cell (fan)
  faces = zeros(N*nT, 3);
  for t = 1:nT
    faces((t-1)*N + (1:N), :) = [col(1), col(t+1), col(t+2)];
  end
  return
end

% --- grid indexing (topological) --------------------------------------------
% basis and integer (i,j) index of each pixel, robust to a smooth distortion
A = latticeBasis(unitCell);            % 2 x 2, columns are the grid step vectors
Ainv = inv(A);
xy = [pos.x(:), pos.y(:)];             % N x 2
ij = assignGridIndex(xy,A);            % N x 2 integer grid index

% corner offset in lattice units, scaled to integers: square -> m=2 (half
% steps), hex -> m=3 (third steps). m is the smallest integer making all
% corner offsets integral. The tolerance is relative and generous: real unit
% cells store rounded decimals (e.g. 3.46 for 2*sqrt(3)) so the exact rational
% is only approximate - a tight tolerance would miss m=3 for hex and fall back
% to m=2, which collapses each hexagon's 6 corners onto 4 nodes (parallelograms).
off = Ainv * [unitCell.x(:).'; unitCell.y(:).'];   % 2 x nC
tol = 1e-2;                                         % lattice units (~1% of a step)
m = 1;
while m <= 12 && ~all(abs(m*off(:) - round(m*off(:))) < tol)
  m = m + 1;
end
if m > 12
  warning('generateUnitCells:latticeScale',...
    'could not find an integer corner scaling; falling back to m=3 (hex) / m=2 (square)');
  m = 2 + (nC == 6);      % 3 for hex, 2 for square
end
coff = round(m * off).';               % nC x 2 integer corner signs

% --- topological key of every corner: m*index + cornerSign ------------------
% column-major layout matches cx(:) (all cells corner 1, then corner 2, ...)
key = zeros(N*nC, 2);
for c = 1:nC
  rows = (c-1)*N + (1:N);
  key(rows,:) = m*ij + coff(c,:);
end

% weld equal nodes; vertex position = mean of the merged corners
[~,~,in] = unique(key,'rows');
nV  = max(in);
cnt = accumarray(in, 1, [nV 1]);
vx  = accumarray(in, cx(:), [nV 1]) ./ cnt;
vy  = accumarray(in, cy(:), [nV 1]) ./ cnt;
vz  = accumarray(in, cz(:), [nV 1]) ./ cnt;

v     = [vx, vy, vz];        % welded vertices, nV x 3
faces = reshape(in, N, nC);  % one row of corner ids per cell, unit-cell order
end