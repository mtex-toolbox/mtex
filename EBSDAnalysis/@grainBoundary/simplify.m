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
%  protect - ids of vertices that must survive, on top of the junctions
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

iStart = find(gB.isChainStart);
iEnd = find(gB.isChainEnd);

% the vertices of a chain are the tails of its segments plus its very last
% head, so a chain of L segments has L+1 vertices
keepEnd = false(nF,1);

for c = 1:numel(iStart)

  s = iStart(c):iEnd(c);
  v = [gB.F(s,1); gB.F(s(end),2)];

  % A closed chain has no ends to anchor the recursion on, so cut it at the
  % vertex furthest from the start - that one is on the hull and survives
  % any tolerance.
  if v(end) == v(1) && numel(v) > 3
    d = sum((xy(v,:) - xy(v(1),:)).^2,2);
    [~,iFar] = max(d);
    keep = false(numel(v),1);
    keep([1 numel(v)]) = true;
    keep(iFar) = true;
    keep(1:iFar) = keep(1:iFar) | douglasPeucker(xy(v(1:iFar),:),epsilon);
    keep(iFar:end) = keep(iFar:end) | douglasPeucker(xy(v(iFar:end),:),epsilon);

    % keep(1) and keep(end) are the same vertex, so this leaves only two
    % distinct ones - a loop that encloses no area. A closed chain is the whole
    % boundary of a grain, so give it a third vertex and keep it a polygon.
    if nnz(keep) < 4
      chord = xy(v(iFar),:) - xy(v(1),:);
      rel = xy(v,:) - xy(v(1),:);
      dOff = abs(rel(:,1)*chord(2) - rel(:,2)*chord(1));
      dOff([1 iFar numel(v)]) = -1;
      [dMax,iOff] = max(dOff);
      if dMax > 0, keep(iOff) = true; end
    end

  else
    keep = douglasPeucker(xy(v,:),epsilon);
  end

  % keeping vertex j of the chain means keeping the end of segment j-1
  keepEnd(s) = keep(2:end);

end

% chain ends are junctions and are never dropped
keepEnd(iEnd) = true;

% a vertex where the neighbouring grains change is a corner of both grain
% polygons even when only two segments meet there - and merging across it would
% have to throw one of the two grainId pairs away. On a full map this coincides
% with a junction, but not on a subset, where the segment between two grains
% that are both outside the subset is gone and its triple point looks ordinary.
keepEnd = keepEnd | isNeighborChange(gB);

% a vertex may also be shared with another boundary object, which finds its
% junctions from its own face list and so cannot see it - grain2d passes
% those in, see grain2d/simplifyBoundary
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
gB = gB.order;

% the surviving junctions are the same ones, but triplePointList.boundaryId
% refers to segment ids and those were just renumbered
gB.triplePoints = gB.calcTriplePoints;

end

% -------------------------------------------------------------------------
function keep = douglasPeucker(xy,epsilon)
% iterative Douglas-Peucker on an open polyline, endpoints always kept

n = size(xy,1);
keep = false(n,1);
keep([1 n]) = true;
if n < 3, return; end

% segments of the polyline still to be examined, as [first last] index pairs
stack = [1 n];

while ~isempty(stack)

  a = stack(end,1); b = stack(end,2);
  stack(end,:) = [];
  if b - a < 2, continue; end

  % distance of every interior point from the chord a-b
  chord = xy(b,:) - xy(a,:);
  rel = xy(a+1:b-1,:) - xy(a,:);
  len = hypot(chord(1),chord(2));

  if len == 0
    d = hypot(rel(:,1),rel(:,2));
  else
    d = abs(rel(:,1)*chord(2) - rel(:,2)*chord(1)) / len;
  end

  [dMax,iMax] = max(d);

  if dMax > epsilon
    iMax = a + iMax;              % back to an index into xy
    keep(iMax) = true;
    stack(end+1,:) = [a iMax];    %#ok<AGROW>
    stack(end+1,:) = [iMax b];    %#ok<AGROW>
  end

end

end
