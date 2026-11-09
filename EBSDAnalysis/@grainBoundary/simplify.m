function gB = simplify(gB,varargin)
% remove vertices that carry no shape information
%
% Syntax
%   gB_s = simplify(gB)
%   gB_s = simplify(gB,epsilon)
%   gB_s = simplify(gB,epsilon,'protect',vertexIds)
%
% Description
% Douglas-Peucker simplification applied to each chain separately. A vertex
% is dropped if removing it moves the boundary by less than epsilon. The
% junctions are the ends of the chains and are always kept, so which grains
% touch, and where, is unchanged.
%
% Unlike reduce, which keeps every n-th vertex regardless of shape, this
% removes many vertices along a straight run and none at a corner. On a
% pixel grid it is what turns a staircase into the straight line it
% approximates.
%
% A grain smaller than epsilon would lose every one of its vertices and
% collapse onto a line. Those grains are left uncoarsened - epsilon says how
% far the boundary may move, not that a grain may be deleted.
%
% Of several vertices at the largest distance the one nearest the middle of
% the piece by arc length is kept, then the one smallest in x, then in y, and
% a loop is cut first at its smallest vertex. So the result depends neither on
% the direction a chain is walked nor on the numbering of the grains.
%
% With |margin| a chord is also refused when it would put the centre of one
% of the pixels next to a pixel edge, see |gB.pixelDist|, on its other side or
% closer to it than margin (de Berg, van Kreveld, Schirra 1998).
%
% Input
%  gB      - @grainBoundary
%  epsilon - tolerance in EBSD units (default: the median segment length over
%            sqrt(2) - a staircase on a grid of spacing d is never further
%            than d/sqrt(2) from the straight line it approximates, the worst
%            case being a boundary at 45 degree, so that is the tolerance
%            which removes the grid and nothing else. At d/2 a 45 degree
%            staircase does not collapse)
%
% Output
%  gB_s - @grainBoundary
%
% Options
%  protect   - ids of vertices that must survive, on top of the junctions
%  margin    - keep the pixel centres on their side, at least this far from the boundary
%  measuredV - the vertex positions the pixel edges were measured at (default: allV)
%
% See also
% grainBoundary/reduce grainBoundary/refine grain2d/simplifyBoundary grain2d/smoothBoundary

nF = length(gB);
if nF == 0, return; end

if ~isempty(varargin) && isnumeric(varargin{1}) && isscalar(varargin{1})
  epsilon = varargin{1};
else
  epsilon = median(gB.segLength) / sqrt(2);
end
if epsilon <= 0, return; end

xy = gB.allV.xyz;
xy = xy(:,1:2);
tau = 1e-9 * epsilon;

% the centres of the two pixels of every pixel edge, as the edge was measured
margin = get_option(varargin,'margin',0);
pd = zeros(nF,1);
if margin > 0 && isProperty(gB,'pixelDist'), pd = gB.prop.pixelDist; end
xy0 = get_option(varargin,'measuredV',xy);
t = xy0(gB.F(:,2),1:2) - xy0(gB.F(:,1),1:2);
off = [-t(:,2) t(:,1)] ./ vecnorm(t,2,2) .* pd / 2;
mid = (xy0(gB.F(:,1),1:2) + xy0(gB.F(:,2),1:2)) / 2;
isPx = pd > 0;

% the chains are stored one after the other, each a polyline through the tails
% of its segments and its very last head, so a chain of L segments has L+1 vertices
F = gB.F;
iStart = find(gB.isChainStart);
iEnd = find(gB.isChainEnd);
L = iEnd - iStart + 1;
ch = repelem((1:numel(L)).',L,1);
deg = accumarray(F(:),1,[size(xy,1) 1]);

% a loop through no junction starts at its smallest vertex, in x and then in y
isLoop = F(iEnd,2) == F(iStart,1) & L > 2;
[~,o] = sortrows([ch xy(F(:,1),:)]);
sh = o([true; diff(ch(o)) > 0]) - iStart;
sh(~isLoop | deg(F(iStart,1)) ~= 2) = 0;
perm = iStart(ch) + mod((1:nF).' - iStart(ch) + sh(ch), L(ch));
vS = iStart + (0:numel(L)-1).';
vE = iEnd + (1:numel(L)).';
v(vE) = F(perm(iEnd),2);
v((1:nF).' + ch - 1) = F(perm,1);
vch = repelem((1:numel(L)).',L+1,1);
P = xy(v,:);
S = [0; cumsum(vecnorm(diff(P),2,2))];

% the pixel centres next to every chain, in the order of the chains
sp = reshape(find(isPx),[],1);
C = reshape([mid(sp,:) + off(sp,:), mid(sp,:) - off(sp,:)].',2,[]).';
nCc = accumarray(ch(sp),2,[numel(L) 1]);

% a closed chain has no ends, so cut it at the vertex furthest from the start
lp = find(isLoop);
[p,g] = expand([vS(lp) vE(lp)]);
far = pick(vecnorm(P(p,:) - P(vS(lp(g)),:),2,2),p,g,P,S,[vS(lp) vE(lp)],tau);
keep = false(numel(v),1);
keep([vS; vE; far]) = true;

% Douglas-Peucker on all pieces at once: a piece splits at its furthest point when
% that is further than epsilon from its chord or the chord crosses a pixel centre
I = [vS(~isLoop) vE(~isLoop); vS(lp) far; far vE(lp)];
while true
  I = I(I(:,2) - I(:,1) >= 2,:);
  if isempty(I), break, end
  [p,g] = expand(I);
  d = chordDist(P,I(g,:),p);
  d(p == I(g,1) | p == I(g,2)) = -inf;
  isS = accumarray(g,d,[],@max) > epsilon + tau;
  isS(~isS) = crosses(P,I(~isS,:),C,nCc,vch,margin);
  i = pick(d(isS(g)),p(isS(g)),g(isS(g)),P,S,I,tau);
  keep(i) = true;
  I = [I(isS,1) i; i I(isS,2)];
end

% keep(1) and keep(end) of a loop are the same vertex, so give the loop a third one
q = accumarray(vch,keep) < 4;
lq = lp(q(lp)); fq = far(q(lp));
[p,g] = expand([vS(lq) vE(lq)]);
d = chordDist(P,[vS(lq(g)) fq(g)],p);
d(p == vS(lq(g)) | p == fq(g) | p == vE(lq(g))) = -inf;
[i,d] = pick(d,p,g,P,S,[vS(lq) vE(lq)],tau);
keep(i(d > 0)) = true;

% keeping vertex j of a chain means keeping the end of its segment j-1
keepEnd = keep((1:nF).' + ch);

% every loop stored from where it starts
gB = gB.subSet(perm);

% chain ends are junctions and are never dropped
keepEnd(iEnd) = true;

% a vertex where the neighbouring grains change is a corner of both grain polygons
keepEnd = keepEnd | isNeighborChange(gB);

% a vertex shared with another boundary object, see grain2d/simplifyBoundary
protect = get_option(varargin,'protect',[]);
if ~isempty(protect)
  isProtected = false(size(gB.allV,1),1);
  isProtected(protect) = true;
  keepEnd = keepEnd | isProtected(gB.F(:,2));
end

% a grain smaller than epsilon would lose every vertex and collapse onto a
% line, so it is left uncoarsened instead
keepEnd = keepGrainPolygons(gB,keepEnd);

surv = find(keepEnd);
if numel(surv) == nF, return; end

% each survivor swallows the run of segments before it
runStart = [1; surv(1:end-1)+1];
FNew = [gB.F(runStart,1), gB.F(surv,2)];

gB = gB.subSet(surv);
gB.F = FNew;

% a segment that swallowed a run runs between no one pair of pixels any more
gB.ebsdId(runStart ~= surv,:) = 0;
if isProperty(gB,'pixelDist'), gB.prop.pixelDist(runStart ~= surv) = 0; end

gB = gB.order;

% the surviving junctions are the same ones, but triplePointList.boundaryId
% refers to segment ids and those were just renumbered
gB.triplePoints = gB.calcTriplePoints;

end

% -------------------------------------------------------------------------
function [p,g] = expand(I)
% the points I(k,1):I(k,2) of every piece k, and k for each of them

I = reshape(I,[],2);
n = I(:,2) - I(:,1) + 1;
g = repelem((1:size(I,1)).',n,1);
p = (1:sum(n)).' - repelem(cumsum(n) - n - I(:,1) + 1,n,1);

end

% -------------------------------------------------------------------------
function d = chordDist(P,I,p)
% distance of the points P(p,:) from the chords P(I(:,1),:) - P(I(:,2),:)

a = P(I(:,1),:);
u = P(I(:,2),:) - a;
r = P(p,:) - a;
len = vecnorm(u,2,2);
d = abs(r(:,1).*u(:,2) - r(:,2).*u(:,1)) ./ len;
d(len == 0) = vecnorm(r(len == 0,:),2,2);

end

% -------------------------------------------------------------------------
function [i,d] = pick(d,p,g,P,S,I,tau)
% for every piece g the point p at the largest distance d - of equal ones the one
% nearest the middle of the piece I(g,:) by arc length S, then the one smallest in
% x, then in y

i = p;
if isempty(p), return, end
mx = accumarray(g,d,[],@max);
c = d >= mx(g) - tau;
p = p(c); g = g(c); d = d(c);
m = abs(S(p) - S(I(g,1)) - (S(I(g,2)) - S(I(g,1)))/2);
mn = accumarray(g,m,[],@min);
c = m <= mn(g) + tau;
p = p(c); g = g(c); d = d(c);
[~,o] = sortrows([g P(p,:)]);
o = o([true; diff(g(o)) > 0]);
i = p(o); d = d(o);

end

% -------------------------------------------------------------------------
function x = crosses(P,I,C,nCc,vch,margin)
% whether the chord of every piece I puts one of the pixel centres C of its
% chain on its other side, or closer to it than margin

x = false(size(I,1),1);
if isempty(C) || isempty(I), return, end

% the pixel centres of the chain within the box of the piece
[p,g] = expand(I);
lo = [accumarray(g,P(p,1),[],@min) accumarray(g,P(p,2),[],@min)] - margin;
hi = [accumarray(g,P(p,1),[],@max) accumarray(g,P(p,2),[],@max)] + margin;
c0 = cumsum(nCc) - nCc;
c = vch(I(:,1));
[q,k] = expand([c0(c) + 1, c0(c) + nCc(c)]);
in = all(C(q,:) >= lo(k,:) & C(q,:) <= hi(k,:),2);
q = q(in); k = k(in);

% closer to the chord than margin
a = P(I(k,1),:);
u = P(I(k,2),:) - a;
r = C(q,:) - a;
t = min(max(sum(r.*u,2) ./ max(sum(u.^2,2),realmin),0),1);
x(k(vecnorm(r - t.*u,2,2) < margin)) = true;

% inside the polygon of the piece and its chord: an odd number of its edges
% crosses the ray from the pixel centre in +x
[e,j] = expand(I(k,:));
n = e + 1;
n(e == I(k(j),2)) = I(k(j(e == I(k(j),2))),1);
y = C(q(j),2);
cr = (P(e,2) > y) ~= (P(n,2) > y) & ...
  C(q(j),1) < P(e,1) + (y - P(e,2)) .* (P(n,1) - P(e,1)) ./ (P(n,2) - P(e,2));
x(k(mod(accumarray(j,cr,[numel(q) 1]),2) == 1)) = true;

end
