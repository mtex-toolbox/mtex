function gB = simplify(gB,epsilon)
% remove vertices that carry no shape information
%
% Syntax
%   gB_s = simplify(gB)
%   gB_s = simplify(gB,epsilon)
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
% Input
%  gB      - @grainBoundary
%  epsilon - tolerance in EBSD units (default: half the median segment length)
%
% Output
%  gB_s - @grainBoundary
%
% See also
% grainBoundary/reduce grainBoundary/refine grain2d/smooth

nF = length(gB);
if nF == 0, return; end

if nargin == 1, epsilon = median(gB.segLength)/2; end
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
  else
    keep = douglasPeucker(xy(v,:),epsilon);
  end

  % keeping vertex j of the chain means keeping the end of segment j-1
  keepEnd(s) = keep(2:end);

end

% chain ends are junctions and are never dropped
keepEnd(iEnd) = true;

surv = find(keepEnd);
if numel(surv) == nF, return; end

% each survivor swallows the run of segments before it
runStart = [1; surv(1:end-1)+1];
FNew = [gB.F(runStart,1), gB.F(surv,2)];

gB = gB.subSet(surv);
gB.F = FNew;
gB = gB.order;

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
