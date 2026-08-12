function check_jcvoronoi
% the Voronoi / Delaunay backends calcGrains segments on must agree
%
% Three claims, over one shared set of point configurations:
%
%   (1) jcvoronoi2.m's pure MATLAB fallback agrees with jcvoronoi2_mex
%   (2) jcvoronoiDelaunayOnly's fallback returns an adjacency superset
%   (3) jcvoronoiDelaunayOnly_mex's adjacency is a superset of jcvoronoi2_mex's
%
% (1) and (2) were check_jcvoronoi2Fallback, (3) was
% check_jcvoronoiDelaunayOnly. They are merged because the two files carried
% squareGridCase, hexGridCase and randomCloudCase as verbatim copies of each
% other, and because both are about the same question: whether the cheaper
% backend can stand in for the full Voronoi build without changing grains.
%
% ---------------------------------------------------------------- claim (1)
%
% MTEX ships no jcvoronoi2_mex for every platform, and calcGrains calls it on
% its main gridded path (spatialDecompositionGrid.m) as well as for the alpha
% complex (spatialDecompositionAlpha.m), so jcvoronoi2.m falls back to a pure
% MATLAB Voronoi build where the binary is missing. This verifies the two
% paths are interchangeable.
%
% They are NOT identical row by row and are not meant to be. Both perturb the
% dummy sites to break the exact cocircular degeneracy of a regular grid - a
% real cell, the dummy outside it and its two lateral neighbours all lie on
% one circle - and they use different perturbations, because MATLAB's uint64
% arithmetic saturates instead of wrapping and cannot reproduce the mex's
% integer hash. Vertex positions therefore differ by a fraction of the weld
% tolerance, and the vertex numbering is unrelated between the two.
%
% What has to hold is the structure calcGrains actually consumes:
%
%   * the same number of vertices, segments and incidences
%   * the same site adjacency, exactly - this is what doSegmentation.m
%     segments on, so any difference here changes the grains
%   * the same segments geometrically, compared by midpoint and length so
%     that neither the row order nor the direction of a segment matters
%   * no measurement point left without a segment
%
% ---------------------------------------------------------------- claim (3)
%
% jcvoronoiDelaunayOnly_mex's site adjacency must always be a SUPERSET of
% jcvoronoi2_mex's on identical input - never missing a true adjacency, only
% possibly adding spurious ones.
%
% calcGrains' minPixel sizing pass (minPixelMask.m) uses
% jcvoronoiDelaunayOnly_mex as a cheaper drop-in for the full jcvoronoi2_mex
% Voronoi build, since doSegmentation.m only ever needs the site adjacency
% A_D = I_FD'*I_FD==1, never the V/F Voronoi geometry.
%
% The two are NOT exactly equal in general: on an exactly regular grid, every
% interior vertex has 4 exactly cocircular sites (the classic square grid
% Delaunay ambiguity). jc_voronoi's sweep arbitrarily keeps one diagonal as a
% Delaunay edge there, even though the true Voronoi cells for those two
% diagonal sites only touch at a single point - a zero length shared edge,
% which jcvoronoi2_mex correctly drops via vertex welding. jcv_delauney_generate
% exposes no vertex or edge length information, so there is no cheap way to
% filter this from the fast path alone.
%
% That is safe for minPixelMask.m: extra adjacency only makes computed grain
% sizes equal or LARGER than the true ones, never smaller, so the 'voronoi'
% sizing method still never over-culls a grain below minPixel. The random
% cloud case has no such degeneracy and is held to exact equality, so a
% genuine implementation bug still fails loudly.
%
% See also
% jcvoronoi2 jcvoronoiDelaunayOnly

if exist('jcvoronoi2_mex','file') ~= 3
  error(['jcvoronoi2_mex is not compiled for ' mexext ...
    ' - there is nothing to compare the fallback against. Run mex_install.']);
end

% the DelaunayOnly binary is guarded separately: claims (1) and (2) are still
% worth running without it, and the original check_jcvoronoiDelaunayOnly had
% no guard at all, so on an un-mexed platform it died with an undefined
% function error instead of a readable message
hasDelaunayMex = exist('jcvoronoiDelaunayOnly_mex','file') == 3;

% -- (1) MATLAB fallback vs mex -------------------------------------------
compareCase(squareGridCase(8,8), 'square grid + dummy ring');
compareCase(hexGridCase(8,8),    'hex grid + dummy ring');
compareCase(randomCloudCase(60), 'random point cloud');
compareCase(duplicateCase(40),   'random cloud with duplicated sites');

% -- (2) DelaunayOnly fallback is a superset ------------------------------
checkDelaunayOnly(squareGridCase(8,8), 'square grid + dummy ring');
checkDelaunayOnly(randomCloudCase(60), 'random point cloud');

% -- (3) DelaunayOnly mex is a superset of the full mex -------------------
if hasDelaunayMex
  compareDelaunayMex(squareGridCase(8,8), 'square grid + dummy ring', false);
  compareDelaunayMex(hexGridCase(8,8),    'hex grid + dummy ring',    false);
  compareDelaunayMex(randomCloudCase(60), 'random point cloud',       true);
else
  fprintf(['  jcvoronoiDelaunayOnly_mex is not compiled for ' mexext ...
    ' - skipping the mex superset check\n']);
end

disp('check_jcvoronoi: the Voronoi backends agree on all cases');

end

% ===========================================================================
function compareDelaunayMex(c, label, requireExact)
% jcvoronoiDelaunayOnly_mex against the full jcvoronoi2_mex

epsTol = c.spacing/100;

[~,~,I_FD_full] = jcvoronoi2_mex(c.XY, c.numReal, epsTol);
I_FD_fast       = jcvoronoiDelaunayOnly_mex(c.XY, c.numReal, epsTol);

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
    '%s, which has no exact cocircular degeneracy to explain them - likely a ' ...
    'real bug, not the known regular grid diagonal artifact'], nExtra, label);
elseif nExtra > 0
  fprintf('  %-38s %d spurious (expected, regular grid diagonal artifact)\n', label, nExtra);
end

end

% ===========================================================================
function compareCase(c, label)

epsTol = c.spacing/100;

[Vm,Fm,Im,repM] = jcvoronoi2(c.XY, c.numReal, epsTol);
[Vf,Ff,If,repF] = jcvoronoi2(c.XY, c.numReal, epsTol, 'noMex');

% -- sizes ----------------------------------------------------------------
assertEq(size(Vm,1), size(Vf,1), label, 'number of vertices');
assertEq(size(Fm,1), size(Ff,1), label, 'number of segments');
assertEq(nnz(Im),    nnz(If),    label, 'number of incidences');

% -- site adjacency, exactly ----------------------------------------------
Am = triu((Im.'*Im)==1, 1);
Af = triu((If.'*If)==1, 1);

nOnlyM = nnz(Am & ~Af);
nOnlyF = nnz(Af & ~Am);
if nOnlyM || nOnlyF
  error(['jcvoronoi2 fallback: site adjacency differs from the mex on %s - ' ...
    '%d pair(s) only the mex reports, %d only the fallback. This changes ' ...
    'which pixels doSegmentation.m can merge, i.e. it changes the grains.'], ...
    label, nOnlyM, nOnlyF);
end

% -- segment geometry, order and direction independent --------------------
% a segment is identified by its midpoint and its length, so that neither the
% row order nor which endpoint comes first has to agree
tol = 2*epsTol;   % both sides jitter the dummies by up to 0.1*epsTol per axis
dMax = matchSets(segKey(Vm,Fm), segKey(Vf,Ff), tol, label, 'segments');
fprintf('  %-38s %4d segments, max deviation %.3g (tolerance %.3g)\n', ...
  label, size(Fm,1), dMax, tol);

% -- no measurement point without a segment -------------------------------
if any(full(sum(If,1)) == 0)
  error(['jcvoronoi2 fallback: %d measurement point(s) have no segment on %s - ' ...
    'the mex contract is that no column of I_FD is empty'], ...
    sum(full(sum(If,1))==0), label);
end

% -- the representative of a merged site ----------------------------------
if ~isequal(repM(:), repF(:))
  error('jcvoronoi2 fallback: siteRep differs from the mex on %s', label);
end

end

% ===========================================================================
function checkDelaunayOnly(c, label)
% the fallback stands in for jcvoronoiDelaunayOnly_mex by returning the full
% Voronoi build
%
% What minPixelMask.m needs is only that the adjacency is a SUPERSET of the
% true one - never missing a pair, since that would under-size a grain and
% wrongly cull it - so the full build satisfies it exactly. This checks that
% the wiring really delivers the full adjacency. It deliberately does not
% compare against the mex: on a regular grid the mex is strictly larger, as
% jcv_delauney_generate keeps one diagonal of every cocircular quad that the
% full build drops as a zero length edge (see check_jcvoronoiDelaunayOnly).

epsTol = c.spacing/100;

I_dl = jcvoronoiDelaunayOnly(c.XY, c.numReal, epsTol, 'noMex');
[~,~,I_full] = jcvoronoi2(c.XY, c.numReal, epsTol, 'noMex');

A_dl   = triu((I_dl.'*I_dl)==1, 1);
A_full = triu((I_full.'*I_full)==1, 1);

nMissing = nnz(A_full & ~A_dl);
if nMissing > 0
  error(['jcvoronoiDelaunayOnly fallback: %d true adjacency pair(s) missing ' ...
    'on %s - minPixelMask.m would under-size a grain and wrongly cull it'], ...
    nMissing, label);
end

end

% ===========================================================================
function K = segKey(V,F)
% midpoint and length of every segment - independent of row order and of
% which endpoint is stored first

P1 = V(F(:,1),:);
P2 = V(F(:,2),:);
K  = [(P1+P2)/2, vecnorm(P1-P2,2,2)];

end

% ===========================================================================
function dMax = matchSets(A, B, tol, label, what)
% every row of A must have a partner in B within tol, and vice versa

if size(A,1) ~= size(B,1)
  error('jcvoronoi2 fallback: %d vs %d %s on %s', size(A,1), size(B,1), what, label);
end
if isempty(A), dMax = 0; return; end

[~,dA] = knnsearch(B,A);
[~,dB] = knnsearch(A,B);

if max(dA) > tol || max(dB) > tol
  error(['jcvoronoi2 fallback: %s on %s deviate by up to %.4g, tolerance is ' ...
    '%.4g - a segment is in a genuinely different place, not merely shifted ' ...
    'by the dummy jitter'], what, label, max([dA;dB]), tol);
end

dMax = max([dA;dB]);

end

% ===========================================================================
function assertEq(a, b, label, what)

if a ~= b
  error('jcvoronoi2 fallback: %s differs on %s - mex %d, fallback %d', ...
    what, label, a, b);
end

end

% ===========================================================================
function c = squareGridCase(nx,ny)
% real sites on a plain integer square lattice, framed by a 1-cell-thick
% dummy ring - the exact cocircular configuration the dummy jitter targets

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
% general position sanity check: irregular points plus a coarse bounding
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

% ===========================================================================
function c = duplicateCase(n)
% exercises the site merging both paths do during construction: every fifth
% measurement point is repeated, displaced well inside the weld tolerance, so
% the two copies have to end up sharing a column of I_FD and one siteRep

c = randomCloudCase(n);

dup = (1:5:n).';
c.XY = [c.XY(1:n,:); c.XY(dup,:) + c.spacing/1000; c.XY(n+1:end,:)];
c.numReal = n + numel(dup);

end
