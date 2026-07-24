function [ij,origin] = assignGridIndex(pos,A)
% robust integer (i,j) lattice index for each point, given a 2x2 basis
%
% Rounds each point's step from its immediate predecessor and accumulates,
% rather than rounding the (potentially large) offset from a single common
% origin in one shot: a smooth but non-affine distortion (e.g. a
% trapezoidal stage drift) can put a far-away point more than half a cell
% from any single global fit, flipping a one-shot round() to the wrong
% integer and colliding two points onto the same cell, while the step
% between two adjacent measurements within a scan line never carries more
% than a tiny fraction of that drift and so always rounds correctly. The
% one step per line that is NOT small - the line-to-line jump back to the
% next line's start - gets the same distortion-robustness treatment
% explicitly in stepwiseIndex (see there). This assumes pos arrives in the
% scan's raster order (row-major or column-major), preserved even through
% logical subsetting (masking only leaves gaps, it never reorders what
% remains).
%
% Falls back to a single global fit if the sequential route still produces
% index collisions (e.g. pos is not in scan order at all, such as after an
% explicit re-sort) - exact for a genuinely rigid grid regardless of point
% order.
%
% Input
%  pos - n x 2 spatial coordinates (map plane only, z is not considered)
%  A   - 2 x 2 lattice basis, columns are the grid step vectors
%
% Output
%  ij     - n x 2 integer lattice index, minimum at [0 0]
%  origin - 1 x 2 physical position corresponding to ij = [0 0]

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
% scan order.
%
% At a line change the raw *inner* step is not a small one-cell move but a
% whole line width. On a rigid grid this still rounds to the exact right
% integer (dividing a large but exact multiple of the cell size by that
% same cell size has no room for ambiguity), which is why the plain
% cumulative sum has always worked for e.g. a hexagonal grid where lines
% need not start at a common column. It stops being trustworthy once the
% line's spacing has actually drifted from the nominal cell size: a tiny
% relative distortion times that large absolute jump can be off by many
% cells while still looking, in isolation, like a fairly clean rounding -
% so whether to trust these raw jumps at all is decided once for the whole
% scan from the worst rounding residual seen at any line change, not line
% by line (a single coincidentally near-integer jump elsewhere doesn't
% make it trustworthy, once other lines show real drift). When distorted,
% every line is instead assumed to start at the same reference inner index
% (0), which is exact for a complete, rectangular scan (not-indexed pixels
% still have a position, so the rectangle has no holes at its edges); it
% is not valid if lines genuinely start at different columns (a scan that
% is missing entire edge pixels rather than marking them not-indexed) and
% is simultaneously distorted enough to be flagged here.
residualTol = 1e-2;

d = diff(pos,1,1);           % (n-1) x 2
dIJ = A \ d.';                % 2 x (n-1)
rd = round(dIJ);

fracZero = mean(rd == 0, 2);
outerIsFirst = fracZero(1) >= fracZero(2);
if outerIsFirst
  outerStep = rd(1,:); innerRaw = dIJ(2,:); innerStep = rd(2,:);
else
  outerStep = rd(2,:); innerRaw = dIJ(1,:); innerStep = rd(1,:);
end

isLineChange = outerStep ~= 0;
isDistorted = any(abs(innerRaw(isLineChange) - innerStep(isLineChange)) > residualTol);

outerCum = [0, cumsum(outerStep)];

rawInnerCum = [0, cumsum(innerStep)];
resetPoint = [true, isDistorted & isLineChange];  % point starts a new line
fillIdx = cummax((1:numel(resetPoint)) .* resetPoint);
innerCum = rawInnerCum - rawInnerCum(fillIdx);    % zero the inner index at each line start

if outerIsFirst
  I = outerCum.'; J = innerCum.';
else
  J = outerCum.'; I = innerCum.';
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
