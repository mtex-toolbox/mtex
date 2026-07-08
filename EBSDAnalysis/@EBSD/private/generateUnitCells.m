function [v,faces] = generateUnitCells(pos,unitCell,varargin)
% generate a list of patches according to spatial coordinates and the unitCell
%
% Input
%  pos      - midpoints of the cells (vector3d)
%  unitCell - spatial coordinates of the unit cell corners (vector3d)
%
% Output
%  v     - list of vertices (nV x 3)
%  faces - list of faces (length(pos) x length(unitCell))
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

nC = length(unitCell);
N  = length(pos);

% corner positions (deformed positions are used only for coordinates)
cx = pos.x(:) + unitCell.x(:).';       % N x nC
cy = pos.y(:) + unitCell.y(:).';
cz = pos.z(:) + unitCell.z(:).';

% --- grid indexing (topological) --------------------------------------------
% basis and integer (i,j) index of each pixel, computed on demand
A = latticeBasis(unitCell);            % 2 x 2, columns are the grid step vectors
Ainv = inv(A);
xy   = [pos.x(:).'; pos.y(:).'];
ij   = Ainv * (xy - min(xy,[],2));     % 2 x N lattice coordinates
ij   = round(ij).';                    % N x 2 integer grid index (deformation-free)

% corner offset in lattice units, scaled to integers: square -> m=2 (half
% steps), hex -> m=3 (third steps). m is the smallest integer making all
% corner offsets integral.
off = Ainv * [unitCell.x(:).'; unitCell.y(:).'];   % 2 x nC
m = 1;
while m <= 12 && ~all(abs(m*off(:) - round(m*off(:))) < 1e-6)
  m = m + 1;
end
if m > 12, m = 2; end
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