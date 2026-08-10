function check_removeQuadruplePoints
% calcGrains(...,'removeQuadruplePoints') must not destroy real boundary
%
% removeQuadruplePoints splits a vertex where four grains meet into two
% triple points by adding a new vertex at the SAME coordinates and a new
% segment joining the two. Every added segment therefore has exactly zero
% length. mergeQuadrupleGrains then merges away those of them that the
% segmentation criterion would not have considered a boundary.
%
% So merging can only ever remove zero length segments. Stated on the
% segment lengths that is exact and order free:
%
%   sort of the non zero segment lengths is identical with and without
%   removeQuadruplePoints
%
% It has to be phrased geometrically rather than on gB.F, because
% removeQuadruplePoints also RENUMBERS vertices: the two edges it detaches
% from a quadruple point get their shared vertex rewritten to the duplicate
% (Ftmp(Ftmp == quadPoints.') = newVid). Those segments keep their geometry
% exactly - the duplicate sits at the same coordinates - but no longer match
% their old F row, so an F based comparison reports ~880 phantom losses on
% forsterite.
%
% The same statement on the sums, sum(grainsQP.boundary.segLength) ==
% sum(grains.boundary.segLength), holds in arithmetic but not in floating
% point: the segments are reordered, and summing them in a different order
% differs in the last bits (4.5e-13 absolute, ~1e-16 relative, on twins).
% Hence a relative tolerance there - 1e-12, nine orders of magnitude below
% the 2.1e-3 the regression below produced.
%
% Regression (TODO.md G38): mergeQuadrupleGrains identified the added
% segments positionally, as gB(end-qAdded+1:end), relying on
% removeQuadruplePoints having appended them to the end of the face list.
% Commit 13d90f5f5 made the grainBoundary constructor sort every segment
% into chain walk order, so those rows were no longer last and the merge
% consumed unrelated, real segments instead - 4529.8 units of genuine grain
% boundary on forsterite, 0.21% of the total, while the grain count moved
% only 2931 -> 2926. The plain reconstruction was untouched, so nothing in
% the benchmark caught it: it records totalLen only for that one.

checkLengthInvariant('forsterite');   % square grid, multi phase
checkLengthInvariant('titanium');     % hex grid
checkLengthInvariant('twins');        % square grid, single phase

disp('removeQuadruplePoints: all checks passed');

end

% =========================================================================
function checkLengthInvariant(name)

ebsd = mtexdata(name,'silent');
e = ebsd('indexed');

g = calcGrains(e);
q = calcGrains(e,'removeQuadruplePoints');

% the exact, order free form: the multiset of real segment lengths is
% untouched, since only zero length segments can be merged away
Lg = sort(g.boundary.segLength(g.boundary.segLength > 0));
Lq = sort(q.boundary.segLength(q.boundary.segLength > 0));

assert(numel(Lg) == numel(Lq) && isequal(Lg,Lq), ...
  ['check_removeQuadruplePoints: %s - the real boundary segments are not ' ...
  'the same with and without removeQuadruplePoints (%d vs %d segments, ' ...
  'total length %.10g vs %.10g). It can only merge away zero length ones, ' ...
  'so it is destroying real boundary.'], ...
  name, numel(Lg), numel(Lq), sum(Lg), sum(Lq));

% and the same thing on the totals, which is what the benchmark records
lg = sum(g.boundary.segLength);
lq = sum(q.boundary.segLength);

assert(abs(lq - lg) <= 1e-12 * lg, ...
  ['check_removeQuadruplePoints: %s - removeQuadruplePoints changed the ' ...
  'total boundary length by %.6g (%.4f%%)'], name, lq - lg, 100*(lq-lg)/lg);

% the QP reconstruction may merge grains, never create them
assert(length(q) <= length(g), ...
  ['check_removeQuadruplePoints: %s - removeQuadruplePoints produced more ' ...
  'grains (%d) than the plain reconstruction (%d)'], name, length(q), length(g));

end
