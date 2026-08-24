function [ij,origin] = assignGridIndex(pos,A)
% robust integer (i,j) lattice index for each point, given a 2x2 basis
%
% Rounds each point's step from its immediate predecessor and accumulates,
% rather than rounding the (potentially large) offset from a single common
% origin in one shot: a smooth but non-affine distortion (e.g. a
% trapezoidal stage drift) can put a far-away point more than half a cell
% from any single global fit, flipping a one-shot round() to the wrong
% integer and colliding two points onto the same cell, while a single-cell
% step never carries more than a tiny fraction of that drift and so always
% rounds correctly. Any BIGGER step - not just the line-to-line jump back
% to the next line's start, but equally a gap of several missing pixels
% within a line (e.g. after selecting one phase out of several) - gets the
% same distortion-robustness treatment explicitly in stepwiseIndex (see
% there). This assumes pos arrives in the scan's raster order (row-major
% or column-major), preserved even through logical subsetting (masking
% only leaves gaps, it never reorders what remains).
%
% Falls back to a single global fit if the sequential route still produces
% index collisions (e.g. pos is not in scan order at all, such as after an
% explicit re-sort) - exact for a genuinely rigid grid regardless of point
% order.
%
% Known limitation: recovering the true index this way needs enough
% single-cell steps nearby to estimate how the local cell size is
% drifting; a combination of both very sparse data (e.g. a rare phase) AND
% very strong distortion (several tens of percent - far beyond a
% realistic stage drift) can leave too few such steps to keep that
% estimate on track. Not an issue for a complete, gap-free scan (nothing
% but line changes are ever a multi-cell step there), nor for a phase
% subset under a realistic amount of distortion.
%
% The two raster orders are not equally easy, either. A distortion along
% the inner direction is measured cell by cell, one along the outer
% direction has to be reconstructed from the drift model in stepwiseIndex,
% so a map whose distortion runs along its outer direction gives out
% earlier. On the forsterite benchmark, both orders are exact up to a
% trapezoidal drift of 49% of a cell along the inner direction and 10%
% along the outer one (2% on the sparsest phase subset) - see
% check_gridDistortionBenchmark, which pins both. A tilt, which distorts
% both directions at once, gives out earlier: 10% read file order and 5%
% read grid order. Realistic stage drift is far below any of these.
%
% This function only recovers the integer index correctly - it does NOT
% by itself make grain reconstruction correct under distortion. Sites with
% no real measurement (notIndexed holes, the map's outer edge) get their
% position from this index through latticeModel, which follows the local
% deformation rather than a rigid affine, so a correct index does carry
% through - but the alpha closing in spatialDecompositionGrid sizes its
% structuring element from the unit cell, and a distortion that changes the
% cell can still flip a borderline single-pixel hole.
%
% Input
%  pos - n × 2 spatial coordinates (map plane only, z is not considered)
%  A   - 2 × 2 lattice basis, columns are the grid step vectors
%
% Output
%  ij     - n × 2 integer lattice index, minimum at [0 0]
%  origin - 1 × 2 physical position corresponding to ij = [0 0]

[I,J] = stepwiseIndex(pos,A);
if hasIndexCollision(I,J)
  [I,J] = globalIndex(pos,A);
end

origin = pos(1,:) + [min(I), min(J)] * A.';
ij = [I - min(I), J - min(J)];

end

% =========================================================================
function [I,J] = stepwiseIndex(pos,A)
% (I,J) from rounding each point's step from its predecessor, accumulated
%
% One lattice direction changes on almost every step (the fast/inner scan
% direction, e.g. the column within a row); the other changes only at the
% rare line-to-line jump (the slow/outer direction, e.g. the row). Which is
% which is decided from the data (the outer one is zero far more often)
% rather than assumed, so this works for both row-major and column-major
% scan order. The outer step is always exactly one cell (or a small,
% unambiguous number of cells if whole lines are missing).
%
% Its rounding used to be trusted outright, which is wrong as soon as the
% distortion runs along the OUTER direction: the line-to-line jump undoes a
% whole line's worth of inner travel in one step, and whatever the outer
% coordinate drifted over that line comes along with it. On twins under a
% 5% trapezoidal drift, read column major, the jump back to the next column
% carried up to 8 cells of x drift, so an outer step that is +1 rounded to
% anything from -7 to +9. The same map read row major was exact, because
% there the distorted direction is the inner one, which was already handled.
% So the outer step is now measured in a LOCAL basis too - see localDrift
% below.
%
% For the inner direction, a single-cell step (the ordinary case within an
% unbroken line) is likewise trusted outright: dividing it by the fixed
% nominal cell size baked into A is only ever off if the local spacing has
% drifted by more than half a cell from that nominal, which one cell's
% worth of drift essentially never does. A BIGGER step - the line-to-line
% jump back to the next line's start, but equally a multi-cell gap within
% a line (e.g. several pixels of a different phase after selecting one out
% of several) - is not: a tiny relative distortion times that large a step
% can be off by many cells while still looking, in isolation, like a
% fairly clean rounding.
%
% Rather than fall back to some fixed assumption about where a line starts
% (which would break for anything other than a complete, gap-free
% rectangle - a phase subset's first surviving pixel in a line can sit at
% any column), every such bigger step is instead measured against the
% *locally observed* cell size, fit once from every trusted single-cell step
% in the whole scan - see fitCellSize. Since a smooth distortion changes
% gradually, this tracks it using all the trusted data at once rather than
% propagating a single nearby sample, and reduces to the plain
% nominal-cell-size division (equivalent to the old unconditional cumulative
% sum) wherever the grid is rigid.
%
% A big step spans a range over which that size itself varies, so it is
% integrated across the step rather than sampled anywhere in it - see
% cellsBetween. Sampling it was enough while the size was modelled as
% varying from line to line only, which is all a trapezoidal drift does; a
% distortion that foreshortens along the scan varies it within the step, and
% a phase subset's gaps are long enough for that to round to the wrong cell.
%
% The outer component of a step gets the mirror image of that treatment.
% A trusted single-cell step carries, besides its one inner cell, a small
% outer displacement - the amount the outer coordinate drifts per inner
% cell. Rounded on its own that is 0, which is why it used to be discarded,
% but it is exactly the quantity a big step needs: over |innerStep| cells it
% accumulates to |innerStep| times as much, and subtracting it turns the
% contaminated jump back into the plain outer step. It is estimated by the
% same regression as the inner scale, is 0 for a rigid grid (so nothing
% changes there), and is 0 as well whenever the distortion runs along the
% inner direction, which is the case that always worked. Note it corrects a
% multi-cell gap WITHIN a line just as it corrects a line change, with no
% need to tell the two apart: the drift subtracted is proportional to the
% inner distance actually travelled.
d = diff(pos,1,1);           % (n-1) × 2
dIJ = A \ d.';                % 2 × (n-1)
rd = round(dIJ);

fracZero = mean(rd == 0, 2);
outerIsFirst = fracZero(1) >= fracZero(2);
if outerIsFirst
  outerRaw = dIJ(1,:); innerRaw = dIJ(2,:); innerStep = rd(2,:);
else
  outerRaw = dIJ(2,:); innerRaw = dIJ(1,:); innerStep = rd(1,:);
end

% read the coordinates off the positions, accumulating them propagates a bad step
coord = A \ (pos - pos(1,:)).';
outerCoord = coord(1 + ~outerIsFirst,:);
innerCoord = coord(2 - ~outerIsFirst,:);
rowMid = (outerCoord(1:end-1) + outerCoord(2:end)) / 2;
colMid = (innerCoord(1:end-1) + innerCoord(2:end)) / 2;

isSingleCell = abs(innerStep) == 1;
isBigStep    = abs(innerStep) >= 2;

% inner cell size, and outer drift per inner cell, as they vary across the map -
% the drift is what is left after rounding, a hex step legitimately moves a cell
outerResid = outerRaw - round(outerRaw);

[scale, scaleSlope] = fitCellSize(colMid, rowMid, isSingleCell, ...
  innerRaw(isSingleCell) ./ innerStep(isSingleCell));
localDrift = fitAcrossMap(rowMid, isSingleCell, ...
  outerResid(isSingleCell) ./ innerStep(isSingleCell), 0);

innerStep(isBigStep) = round(cellsBetween(innerCoord(1:end-1), innerCoord(2:end), ...
  scale, scaleSlope, colMid, isBigStep));
outerStep = round(outerRaw - innerStep .* localDrift);

outerCum = [0, cumsum(outerStep)];
innerCum = [0, cumsum(innerStep)];

if outerIsFirst
  I = outerCum.'; J = innerCum.';
else
  J = outerCum.'; I = innerCum.';
end
end

% =========================================================================
function [scale, slope] = fitCellSize(colMid, rowMid, isSingleCell, obs)
% local inner cell size, as an affine function of BOTH lattice coordinates
%
% Fitting it across the map alone (fitAcrossMap) makes it constant along the
% inner direction, which is right for a trapezoidal drift - there the inner
% cell size is exactly nominal everywhere - but not for a distortion that
% foreshortens along the scan. Under a perspective the size varies along the
% inner direction and barely at all across it, i.e. in precisely the
% direction the older model held fixed.
%
% Returns the size at each step (scale) plus how it varies per unit of inner
% coordinate (slope), which is what cellsBetween needs to integrate it.

n = nnz(isSingleCell);
slope = 0;

if n >= 3 && range(colMid(isSingleCell)) > 0
  % in double throughout - real imported maps arrive as single, and the fit
  % is what the integrated step size below is most sensitive to
  X = double([ones(n,1), colMid(isSingleCell).', rowMid(isSingleCell).']);
  p = X \ double(obs(:));
  slope = p(2);
  scale = p(1) + p(2)*colMid + p(3)*rowMid;
elseif n >= 2 && range(rowMid(isSingleCell)) > 0
  coeffs = [ones(n,1), rowMid(isSingleCell).'] \ obs(:);
  scale = coeffs(1) + coeffs(2) * rowMid;
elseif n >= 1
  scale = repmat(mean(obs), 1, numel(rowMid));
else
  scale = ones(1, numel(rowMid));
end

end

% =========================================================================
function step = cellsBetween(c1, c2, scale, slope, colMid, sel)
% how many lattice cells separate two inner coordinates
%
% A step of many cells spans a range over which the cell size itself varies,
% so dividing by the size at any single point is wrong - what the index needs
% is the integral of dc / size(c). For a size that is affine along the inner
% direction that integral is exact rather than a quadrature.
%
% Written through log1p(z)/z rather than log(s2/s1)/slope: on a near rigid
% grid the fitted slope is numerical noise, and dividing a logarithm of
% something indistinguishable from 1 by it loses every digit - single
% precision maps segmented differently for it. log1p(z)/z tends to 1 as the
% size stops varying, so this degenerates cleanly to the plain division it
% replaces instead of needing a threshold to switch over.

c1 = double(c1(sel)); c2 = double(c2(sel));
s  = double(scale(sel));
slope = double(slope);

% the fitted size is anchored at the step's own midpoint
s1 = s - slope * (double(colMid(sel)) - c1);

dc = c2 - c1;
z  = slope * dc ./ s1;

w = ones(size(z));
vary = abs(z) > 1e-6 & isfinite(z);
w(vary) = log1p(z(vary)) ./ z(vary);

step = dc ./ s1 .* w;

% a size that is not positive throughout means the fit has run away
bad = ~(s1 > 0 & s1 + slope*dc > 0) | ~isfinite(step);
step(bad) = dc(bad) ./ s(bad);

end

% =========================================================================
function val = fitAcrossMap(rowMid, isSingleCell, obs, fallback)
% linear regression of a per-step observation on the outer coordinate
%
% Fit from the trusted single-cell steps only and evaluated at every step,
% so a quantity that drifts smoothly across the map is available where it is
% needed - at the steps that are not trusted. Degenerates to the mean, and
% then to fallback, when there is not enough to fit.

rows = rowMid(isSingleCell);

if nnz(isSingleCell) >= 2 && range(rows) > 0
  coeffs = [ones(numel(rows),1), rows(:)] \ obs(:);  % [intercept; slope]
  val = coeffs(1) + coeffs(2) * rowMid;
elseif nnz(isSingleCell) >= 1
  val = repmat(mean(obs), 1, numel(rowMid));
else
  val = repmat(fallback, 1, numel(rowMid));
end
end

% =========================================================================
function [I,J] = globalIndex(pos,A)
% (I,J) from rounding each point's offset from a single common origin

IJ = A \ (pos - pos(1,:)).';
I = round(IJ(1,:)).';
J = round(IJ(2,:)).';
end

% =========================================================================
function tf = hasIndexCollision(I,J)
% true if two points were assigned the same (I,J) cell

key = (I - min(I)) + (max(I) - min(I) + 1) * (J - min(J));
tf = numel(unique(key)) < numel(I);
end
