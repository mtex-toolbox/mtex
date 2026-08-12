function check_mexFunctions
% the compiled binaries must compute the right answer, not merely run
%
% check_mex is an installer - startup_mtex calls it on every start - and it
% prints its results rather than raising, so `matlab -batch "check_mex"`
% exits 0 whether every binary works or none does. Several of its per-mex
% checks are also not checks at all: check_jcvoronoi_mex, check_EulerCyclesC,
% check_nfftmex, check_fptmex, check_S1Grid_find_region, check_S2Grid_find
% and check_S2Grid_find_region call the binary and then hardcode out = 1, and
% the two S2 ones only time it.
%
% This file asserts. It covers the binaries whose result can be checked
% against an independent reference cheaply:
%
%   insidepoly (both engines)   against inpolygon
%   EulerCyclesC                against its own structural contract
%   S1Grid_find / _find_region  against brute force
%   S2Grid_find / _find_region  against brute force
%   SO3Grid_find / _find_region / _dist_region  against brute force
%
% Not here: chainOrderC and the jcvoronoi family, which have their own files
% (check_chainOrder, check_jcvoronoi); and the NFFT family, which every
% harmonic test exercises indirectly - nfsft, nfsoft, wignerTrafo all have
% value checks in check_mex already, and they are too expensive for core.
%
% See also
% check_mex check_mexComplete check_chainOrder check_jcvoronoi

rng(0)

checkInsidepoly;
checkEulerCycles;
checkS1GridFind;
checkS2GridFind;
checkSO3GridFind;

disp('check_mexFunctions: passed');

end

% =========================================================================
function checkInsidepoly
% insidepoly must agree with MATLAB's own inpolygon, in both engines
%
% check_mex computes exactly this and then throws the answer away.

n = 2000;
x = rand(n,1)*4 - 2;
y = rand(n,1)*4 - 2;

% a non convex polygon, so that a naive convex test would fail
t = linspace(0,2*pi,13).';
poly = [cos(t).*(1+0.5*cos(5*t)), sin(t).*(1+0.5*cos(5*t))];

ref = inpolygon(x,y,poly(:,1),poly(:,2));

got = insidepoly(x,y,poly(:,1),poly(:,2));
assert(isequal(logical(got(:)),ref(:)), ...
  'check_mexFunctions: insidepoly disagrees with inpolygon on %d of %d points', ...
  nnz(logical(got(:)) ~= ref(:)), n)

% and the single precision engine, on the same geometry
gotS = insidepoly(single(x),single(y),single(poly(:,1)),single(poly(:,2)));

% points within a whisker of the edge may legitimately fall the other way in
% single precision, so those are excluded rather than demanded
d = pointToPolyDistance(x,y,poly);
safe = d > 1e-4;
assert(isequal(logical(gotS(safe)),ref(safe)), ...
  ['check_mexFunctions: the single precision insidepoly disagrees with ' ...
   'inpolygon on %d of %d points that are not near an edge'], ...
  nnz(logical(gotS(safe)) ~= ref(safe)), nnz(safe))

end

% =========================================================================
function checkEulerCycles
% EulerCyclesC returns a nested CSR - g indexes into c, c indexes into cP -
% and every cycle it emits has to be a closed walk over real vertices
%
% check_mex calls it and hardcodes out = 1.

ebsd = mtexdata('small','silent');
grains = calcGrains(ebsd('indexed'));
gB = grains.boundary;

nV = length(gB.allV);
[g,c,cP] = EulerCyclesC(gB.I_FG,gB.F,nV);

% -- the two offset arrays must close on the arrays they index ------------
assert(c(end) == numel(cP)+1, ...
  'check_mexFunctions: EulerCyclesC - c ends at %d but cP has %d entries', ...
  c(end), numel(cP))
assert(g(end) == numel(c), ...
  'check_mexFunctions: EulerCyclesC - g ends at %d but c has %d entries', ...
  g(end), numel(c))

assert(all(diff(g) >= 0) && all(diff(c) >= 0), ...
  'check_mexFunctions: EulerCyclesC - the offset arrays are not monotone')

% -- every referenced vertex must exist -----------------------------------
assert(all(cP >= 1 & cP <= nV), ...
  'check_mexFunctions: EulerCyclesC - a cycle references a vertex outside 1..%d', nV)

% -- every cycle must be closed and be a real polygon ---------------------
nCycles = numel(c) - 1;
assert(nCycles > 0, 'check_mexFunctions: EulerCyclesC returned no cycles at all')

for k = 1:nCycles
  idx = c(k):c(k+1)-1;
  assert(numel(idx) >= 4, ...
    'check_mexFunctions: EulerCyclesC - cycle %d has only %d vertices', k, numel(idx))
  assert(cP(idx(1)) == cP(idx(end)), ...
    'check_mexFunctions: EulerCyclesC - cycle %d is not closed, %d ~= %d', ...
    k, cP(idx(1)), cP(idx(end)))
end

end

% =========================================================================
function checkS1GridFind
% S1Grid_find and S1Grid_find_region against brute force, periodic and not

pts = [1 2 3 4 9];
x = S1Grid(pts,0,10);

assert(find(x,3.2) == 3, 'check_mexFunctions: S1Grid_find missed the nearest point')

% periodic: 0.1 is nearest to 9.8, which is only true if the wrap is honoured
xp = S1Grid([pts 9.8],0,10,'periodic');
assert(find(xp,0.1) == 6, ...
  'check_mexFunctions: the periodic S1Grid_find did not wrap around')

% brute force over a dense grid, non periodic
q = linspace(0.5,9.5,200);
for k = 1:numel(q)
  [~,ref] = min(abs(pts - q(k)));
  got = find(x,q(k));
  assert(got == ref, ...
    'check_mexFunctions: S1Grid_find gave %d, brute force %d, for %.3f', ...
    got, ref, q(k))
end

% the region form returns a sparse logical MASK over the grid points, not a
% list of indices. The radius is deliberately not a round number: with
% eps = 2.5 a grid point sits at exactly that distance and whether it counts
% is a strict/non strict question rather than a correctness one.
eps1 = 2.6;
for k = 1:20:numel(q)
  ref = find(abs(pts - q(k)) < eps1);
  got = find(full(logical(find(x,q(k),eps1))));
  assert(isequal(got(:).',ref(:).'), ...
    'check_mexFunctions: S1Grid_find_region gave %s, brute force %s, for %.3f', ...
    mat2str(got(:).'), mat2str(ref(:).'), q(k))
end

end

% =========================================================================
function checkS2GridFind
% S2Grid_find and S2Grid_find_region against brute force
%
% check_mex only times these two and returns 1.

x = equispacedS2Grid('points',500);
xv = vector3d(x);
y = vector3d.rand(40);

% -- nearest ---------------------------------------------------------------
got = find(x,y);

assert(numel(got) == numel(y), ...
  'check_mexFunctions: S2Grid_find returned %d indices for %d queries', ...
  numel(got), numel(y))

% compared through the dot_outer matrix rather than by calling angle on the
% two lists: angle() broadcasts a column against a column into an outer
% product, so the elementwise reading would silently become 40x40. Ties are
% possible on a regular grid, so the returned point only has to be AS close
% as the best one, not carry the same index.
D = dot_outer(xv,y);
[best,~] = max(D,[],1);
lin = sub2ind(size(D),double(got(:)).',1:numel(y));

% S2Grid_find is not exact: it searches the nearest ring of constant theta
% and then within it, and near a cell boundary it can settle on a neighbour.
% Measured over 200 queries on a 510 point grid (spacing 9.0 degree): 4 of
% them come back with a neighbouring point, overshooting the true nearest by
% at most 0.84 degree and always staying inside one cell. The tolerance
% below is a fifth of the grid spacing - loose enough for that tie breaking,
% far too tight for a binary that is actually returning the wrong point.
spacing = sqrt(4*pi/numel(xv));
extra = acos(min(1,D(lin))) - acos(min(1,best));

assert(max(extra) < 0.2*spacing, ...
  ['check_mexFunctions: S2Grid_find returned a point %.2f degree further ' ...
   'away than the nearest, more than a fifth of the %.2f degree grid spacing'], ...
  max(extra)/degree, spacing/degree)

% -- within a radius -------------------------------------------------------
% like the S1 version this returns a sparse logical MASK over the grid, not
% a list of indices
eps1 = 0.35;
for k = 1:5:numel(y)

  got = find(full(logical(find(x,y(k),eps1))));

  d = angle(xv,y(k));

  % the boundary of the radius is a strict/non strict question, so only the
  % clearly inside and the clearly outside points are demanded
  inside = find(d < eps1 - 1e-6);
  outside = find(d > eps1 + 1e-6);

  assert(~isempty(inside), ...
    'check_mexFunctions: the S2 radius caught nothing, the check is vacuous')
  assert(all(ismember(inside,got)), ...
    'check_mexFunctions: S2Grid_find_region missed %d of %d points inside the radius', ...
    nnz(~ismember(inside,got)), numel(inside))
  assert(~any(ismember(outside,got)), ...
    'check_mexFunctions: S2Grid_find_region returned %d points outside the radius', ...
    nnz(ismember(outside,got)))

end

end

% =========================================================================
function checkSO3GridFind
% SO3Grid_find, SO3Grid_find_region and SO3Grid_dist_region against brute
% force

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs,'resolution',5*degree);

ori = orientation.rand(cs);

% -- nearest ---------------------------------------------------------------
i = find(S3G,ori);
d = angle(S3G,ori);
assert(abs(d(i) - min(d(:))) < 1e-9, ...
  'check_mexFunctions: SO3Grid_find returned a point %.3g degree from the nearest', ...
  (d(i)-min(d(:)))/degree)

% -- within a radius -------------------------------------------------------
eps1 = 10*degree;
ind = find(S3G,ori,eps1);
ref = angle(S3G,ori) < eps1;
assert(nnz(ref) > 0, ...
  'check_mexFunctions: the SO3 radius caught nothing, the check is vacuous')
assert(all(logical(ind(:)) == ref(:)), ...
  'check_mexFunctions: SO3Grid_find_region disagrees with brute force on %d points', ...
  nnz(logical(ind(:)) ~= ref(:)))

% -- the epsilon shortcut must not change the distances it does report -----
d1 = angle_outer(S3G,ori,'epsilon',eps1);
d2 = angle_outer(S3G,ori);
near = d2 < eps1/2;
assert(nnz(near) > 0, ...
  'check_mexFunctions: SO3Grid_dist_region has nothing to compare, the check is vacuous')
assert(max(abs(d2(near) - d1(near))) < 1e-9, ...
  ['check_mexFunctions: SO3Grid_dist_region with an epsilon gives different ' ...
   'distances than without, by up to %.3g degree'], ...
  max(abs(d2(near) - d1(near)))/degree)

end

% =========================================================================
function d = pointToPolyDistance(x,y,poly)
% shortest distance from each point to the polygon outline, used only to
% keep points off the edge out of the single precision comparison

P1 = poly(1:end-1,:);
P2 = poly(2:end,:);

d = inf(numel(x),1);
for k = 1:size(P1,1)
  a = P1(k,:); b = P2(k,:);
  ab = b - a;
  t = max(0,min(1, ((x-a(1))*ab(1) + (y-a(2))*ab(2)) / (ab*ab.') ));
  d = min(d, hypot(x - (a(1)+t*ab(1)), y - (a(2)+t*ab(2))));
end

end
