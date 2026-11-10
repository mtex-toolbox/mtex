function check_removeQuadruplePoints
% removeQuadruplePoints must not destroy real boundary
%
% The split of a quadruple point moves the ends of its four segments by an
% eighth of a pixel and adds the neck between the two joined pixels, which
% mergeQuadrupleGrains merges away. Every segment farther than a quarter
% pixel from every quadruple point is therefore untouched, stated on the
% multiset of their lengths so that the renumbering of the vertices and the
% walk order play no part. A merge that consumed unrelated segments, as a
% positional identification of the added ones once did (TODO.md G38, 0.21
% percent of forsterite's boundary length), fails it.
%
% Named maps rather than every map: merge drops every segment whose two
% sides end up in the same grain, so where a quadruple point merge joins two
% grains that also touch along a real boundary elsewhere, that boundary goes
% too - correctly. steel1C_1 loses 55.4 that way; forsterite, titanium and
% twins never hit the case.

checkLengthInvariant('forsterite');   % square grid, multi phase
checkLengthInvariant('titanium');     % hex grid
checkLengthInvariant('twins');        % square grid, single phase

disp('removeQuadruplePoints: all checks passed');

end

% =========================================================================
function checkLengthInvariant(name)

ebsd = mtexdata(name,'silent');
e = ebsd('indexed');

g = calcGrains(e,'removeQuadruplePoints',false);
q = calcGrains(e);

V = g.boundary.allV.xyz;
P = V(accumarray(g.boundary.F(:),1) == 4,1:2);
d = median(g.boundary.segLength);

Lg = farLengths(g.boundary,P,d);
Lq = farLengths(q.boundary,P,d);

assert(numel(Lg) == numel(Lq) && isequal(Lg,Lq), ...
  ['check_removeQuadruplePoints: %s - the segments away from the quadruple ' ...
  'points are not the same with and without removeQuadruplePoints (%d vs %d ' ...
  'segments, total length %.10g vs %.10g)'], name, numel(Lg), numel(Lq), sum(Lg), sum(Lq));

% four segment ends per point move by at most an eighth of a pixel
lg = sum(g.boundary.segLength);
lq = sum(q.boundary.segLength);
assert(abs(lq - lg) <= size(P,1) * d / 2, ...
  ['check_removeQuadruplePoints: %s - removeQuadruplePoints changed the ' ...
  'total boundary length by %.6g (%.4f%%) at %d quadruple points'], ...
  name, lq - lg, 100*(lq-lg)/lg, size(P,1));

% the QP reconstruction may merge grains, never create them
assert(length(q) <= length(g), ...
  ['check_removeQuadruplePoints: %s - removeQuadruplePoints produced more ' ...
  'grains (%d) than the plain reconstruction (%d)'], name, length(q), length(g));

end

% =========================================================================
function L = farLengths(gB,P,d)
% the sorted lengths of the segments with no end within d/4 of a point of P

near = false(size(gB.allV,1),1);
X = gB.allV.xyz;
if ~isempty(P), near = min(pdist2(X(:,1:2),P),[],2) < d/4; end
L = sort(gB.segLength(~any(near(gB.F),2)));

end
