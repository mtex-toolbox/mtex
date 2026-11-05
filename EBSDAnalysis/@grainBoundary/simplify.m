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

iStart = find(gB.isChainStart);
iEnd = find(gB.isChainEnd);
deg = accumarray(gB.F(:),1,[size(xy,1) 1]);

% the vertices of a chain are the tails of its segments plus its very last
% head, so a chain of L segments has L+1 vertices
keepEnd = false(nF,1);
perm = (1:nF).';

for c = 1:numel(iStart)

  s = iStart(c):iEnd(c);

  % a loop through no junction starts at its smallest vertex, in x and then in y
  isLoop = gB.F(s(end),2) == gB.F(s(1),1) && numel(s) > 2;
  if isLoop && deg(gB.F(s(1),1)) == 2
    [~,k] = sortrows(xy(gB.F(s,1),:));
    perm(s) = s([k(1):end 1:k(1)-1]);
  end
  v = [gB.F(perm(s),1); gB.F(perm(s(end)),2)];
  sp = s(isPx(s));
  C = [mid(sp,:) + off(sp,:); mid(sp,:) - off(sp,:)];

  % a closed chain has no ends, so cut it at the vertex furthest from the start
  if isLoop
    iFar = pick(vecnorm(xy(v,:) - xy(v(1),:),2,2),xy(v,:),tau);
    keep = false(numel(v),1);
    keep([1 numel(v)]) = true;
    keep(iFar) = true;
    keep(1:iFar) = keep(1:iFar) | douglasPeucker(xy(v(1:iFar),:),epsilon,C,margin);
    keep(iFar:end) = keep(iFar:end) | douglasPeucker(xy(v(iFar:end),:),epsilon,C,margin);

    % keep(1) and keep(end) are the same vertex, so give the loop a third one
    if nnz(keep) < 4
      chord = xy(v(iFar),:) - xy(v(1),:);
      rel = xy(v,:) - xy(v(1),:);
      dOff = abs(rel(:,1)*chord(2) - rel(:,2)*chord(1)) / norm(chord);
      dOff([1 iFar numel(v)]) = -inf;
      iOff = pick(dOff,xy(v,:),tau);
      if dOff(iOff) > 0, keep(iOff) = true; end
    end

  else
    keep = douglasPeucker(xy(v,:),epsilon,C,margin);
  end

  % keeping vertex j of the chain means keeping the end of segment j-1
  keepEnd(s) = keep(2:end);

end

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
function keep = douglasPeucker(xy,epsilon,C,margin)
% iterative Douglas-Peucker on an open polyline, endpoints always kept. A
% chord is refused when a point lies further than epsilon from it, or when it
% puts a point of C on its other side or closer to it than margin

n = size(xy,1);
keep = false(n,1);
keep([1 n]) = true;
tau = 1e-9 * epsilon;

% segments of the polyline still to be examined, as [first last] index pairs
stack = [1 n];

while ~isempty(stack)

  a = stack(end,1); b = stack(end,2);
  stack(end,:) = [];
  if b - a < 2, continue; end

  % distance of every point from the chord a-b, the ends left out
  chord = xy(b,:) - xy(a,:);
  rel = xy(a:b,:) - xy(a,:);
  len = norm(chord);
  if len == 0
    d = vecnorm(rel,2,2);
  else
    d = abs(rel(:,1)*chord(2) - rel(:,2)*chord(1)) / len;
  end
  d([1 end]) = -inf;

  if max(d) > epsilon + tau || crosses(xy(a:b,:),C,margin)
    i = a - 1 + pick(d,xy(a:b,:),tau);
    keep(i) = true;
    stack(end+1:end+2,:) = [a i; i b];
  end

end

end

% -------------------------------------------------------------------------
function i = pick(d,xy,tau)
% the point of the polyline xy at the largest distance d - of equal ones the
% one nearest its middle by arc length, then the one smallest in x, then in y

s = [0; cumsum(vecnorm(diff(xy),2,2))];
i = find(d >= max(d) - tau);
m = abs(s(i) - s(end)/2);
i = i(m <= min(m) + tau);
[~,j] = sortrows(xy(i,:));
i = i(j(1));

end

% -------------------------------------------------------------------------
function out = crosses(P,C,margin)
% whether the chord from the first to the last point of P puts a point of C
% on its other side, or closer to it than margin

C = C(all(C >= min(P,[],1) - margin & C <= max(P,[],1) + margin,2),:);
u = P(end,:) - P(1,:);
t = min(max((C - P(1,:)) * u.' / max(u * u.',realmin),0),1);
out = any(vecnorm(C - P(1,:) - t .* u,2,2) < margin) || ...
  any(inpolygon(C(:,1),C(:,2),P(:,1),P(:,2)));

end
