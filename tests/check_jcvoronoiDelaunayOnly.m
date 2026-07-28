function check_jcvoronoiDelaunayOnly
% jcvoronoiDelaunayOnly_mex's site adjacency must always be a SUPERSET of
% jcvoronoi2_mex's on identical input - never missing a true adjacency, only
% possibly adding spurious ones
%
% calcGrains' minPixel sizing pass (minPixelMask.m) uses
% jcvoronoiDelaunayOnly_mex as a cheaper drop-in for the full jcvoronoi2_mex
% Voronoi build, since doSegmentation.m only ever needs the site adjacency
% A_D = I_FD'*I_FD==1, never the V/F Voronoi geometry (see
% spatialDecompositionGrid.m).
%
% The two are NOT exactly equal in general: on an exactly regular/rigid grid,
% every interior vertex has 4 exactly-cocircular sites (the classic square-
% grid Delaunay ambiguity). jc_voronoi's sweep arbitrarily keeps one diagonal
% as a Delaunay edge there, even though the true Voronoi cells for those two
% diagonal sites only touch at a single point (a zero-length shared edge,
% which jcvoronoi2_mex correctly drops via vertex welding, v1==v2). Since
% jcv_delauney_generate exposes no vertex/edge-length information (confirmed
% by reading jcv_delauney_next: next->pos is just the two site positions),
% there is no cheap way to filter this from the fast path alone.
%
% This is safe for minPixelMask.m's purpose: extra adjacency only makes
% computed grain sizes equal or LARGER than the true ones (never smaller), so
% the 'voronoi' sizing method still never over-culls a grain that is really
% below minPixel; it can only rarely fail to cull one that touches a
% same-sized neighbour purely diagonally on a perfectly regular grid
% (accepted tradeoff, see idea_minpixel_delaunay_first_pass memory / 2026-07-24
% follow-up). The random point cloud case below has no such degeneracy and is
% held to exact equality, so a genuine implementation bug still fails loudly.

compareCase(squareGridCase(8,8), 'square grid + dummy ring', false);
compareCase(hexGridCase(8,8),    'hex grid + dummy ring', false);
compareCase(randomCloudCase(60), 'random point cloud', true);

disp('jcvoronoiDelaunayOnly_mex: adjacency is a safe superset of jcvoronoi2_mex on all cases');

end

% ===========================================================================
function compareCase(c, label, requireExact)

epsTol = c.spacing/100;

[~,~,I_FD_full] = jcvoronoi2_mex(c.XY, c.numReal, epsTol);
I_FD_fast        = jcvoronoiDelaunayOnly_mex(c.XY, c.numReal, epsTol);

A_full = triu((I_FD_full.'*I_FD_full)==1, 1);
A_fast = triu((I_FD_fast.'*I_FD_fast)==1, 1);

nMissing = nnz(A_full & ~A_fast);
if nMissing > 0
  error(['jcvoronoiDelaunayOnly_mex is missing %d true adjacency pair(s) that ' ...
    'jcvoronoi2_mex reports on %s - this would let minPixelMask.m under-size ' ...
    'a grain and wrongly cull it'], nMissing, label);
end

nExtra = nnz(A_fast & ~A_full);
if requireExact && nExtra > 0
  error(['jcvoronoiDelaunayOnly_mex reports %d spurious adjacency pair(s) on ' ...
    '%s, which has no exact-cocircular degeneracy to explain them - likely a ' ...
    'real bug, not the known regular-grid diagonal artifact'], nExtra, label);
elseif nExtra > 0
  fprintf('  %s: %d spurious (expected, regular-grid diagonal artifact)\n', label, nExtra);
end

end

% ===========================================================================
function c = squareGridCase(nx,ny)
% real sites on a plain integer square lattice, framed by a 1-cell-thick
% dummy ring - the exact co-circular configuration the dummy jitter targets

[X,Y] = meshgrid(1:nx,1:ny);
real = [X(:) Y(:)];

[Xd,Yd] = meshgrid(0:nx+1,0:ny+1);
dummy = [Xd(:) Yd(:)];
isReal = Xd(:)>=1 & Xd(:)<=nx & Yd(:)>=1 & Yd(:)<=ny;
dummy = dummy(~isReal,:);

c.XY = [real; dummy];
c.numReal = size(real,1);
c.spacing = 1;

end

% ===========================================================================
function c = hexGridCase(nx,ny)
% real sites on a triangular (hex) lattice, framed by a dummy ring one row/
% column beyond the real block on all sides

[col,row] = meshgrid(0:nx-1,0:ny-1);
x = col + mod(row,2)*0.5;
y = row*sqrt(3)/2;
real = [x(:) y(:)];

[colD,rowD] = meshgrid(-1:nx,-1:ny);
xD = colD + mod(rowD,2)*0.5;
yD = rowD*sqrt(3)/2;
dummy = [xD(:) yD(:)];
isReal = colD(:)>=0 & colD(:)<=nx-1 & rowD(:)>=0 & rowD(:)<=ny-1;
dummy = dummy(~isReal,:);

c.XY = [real; dummy];
c.numReal = size(real,1);
c.spacing = 1;

end

% ===========================================================================
function c = randomCloudCase(n)
% general-position sanity check: irregular points plus a coarse bounding
% dummy ring, no lattice degeneracy

rng(0,'twister');
real = rand(n,2)*10;

nb = 12;
theta = (0:nb-1)'/nb*2*pi;
dummy = 5 + 8*[cos(theta) sin(theta)];

c.XY = [real; dummy];
c.numReal = n;
c.spacing = 10/sqrt(n);

end
