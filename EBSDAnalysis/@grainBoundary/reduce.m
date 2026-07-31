function gB = reduce(gB,varargin)
% coarsen a list of grain boundary segments
%
% Syntax
%   gB_red = reduce(gB)
%   gB_red = reduce(gB,n)
%   gB_red = reduce(gB,n,'protect',vertexIds)
%
% Description
% Dissolves every vertex that is not needed, keeping only every n-th one
% along each chain. Junctions are always kept, so the topology of the
% boundary network is preserved - which grains touch which, and where, is
% unchanged. This merges segments rather than dropping them, so the boundary
% stays connected and its total length is preserved up to the straightening
% of the removed corners.
%
% A grain that would be left with fewer than three vertices, and so collapse
% onto a line, is not coarsened at all.
%
% The properties of the merged segments - grainId, ebsdId, misrotation - are
% inherited from the last segment of each run. They are constant along a
% chain anyway, apart from misrotation.
%
% Input
%  gB - @grainBoundary
%  n  - keep every n-th vertex (default 2)
%
% Output
%  gB_red - @grainBoundary
%
% Options
%  protect - ids of vertices that must survive, on top of the junctions
%
% See also
% grainBoundary/simplify grainBoundary/order grain2d/reduceBoundary EBSD/reduce

if ~isempty(varargin) && isnumeric(varargin{1}) && isscalar(varargin{1})
  factor = varargin{1};
else
  factor = 2;
end

nF = length(gB);
if nF == 0 || factor <= 1, return; end

% -- which end vertices survive ------------------------------------------
isEnd = gB.isChainEnd;
iStart = find(gB.isChainStart);
posInChain = (1:nF).' - iStart(gB.chainId);

% chain ends are junctions and always survive
keepEnd = isEnd | mod(posInChain+1,factor) == 0;

% a vertex where the neighbouring grains change has to be kept too, even when
% only two segments meet there - see isNeighborChange
keepEnd = keepEnd | isNeighborChange(gB);

% a vertex may also be shared with another boundary object, which finds its
% junctions from its own face list and so cannot see it - grain2d passes
% those in, see grain2d/reduceBoundary
protect = get_option(varargin,'protect',[]);
if ~isempty(protect)
  isProtected = false(size(gB.allV,1),1);
  isProtected(protect) = true;
  keepEnd = keepEnd | isProtected(gB.F(:,2));
end

% A closed chain has no junction to anchor it, so nothing above is guaranteed to
% leave it with three vertices - and two enclose no area. A closed chain is the
% entire boundary of a grain, so keep it a polygon.
iEnd = find(isEnd);
chainId = gB.chainId;
isClosedCh = gB.F(iEnd,2) == gB.F(iStart,1);
nKeep = accumarray(chainId,keepEnd,[numel(iStart) 1]);

for c = reshape(find(isClosedCh & nKeep < 3),1,[])
  s = iStart(c):iEnd(c);
  if numel(s) < 3, continue; end
  keepEnd(s(unique(round(linspace(numel(s)/3,numel(s),3))))) = true;
end

% and a grain whose vertices are spread over several open chains needs the same
% floor - a single pixel grain has two chains of two segments
keepEnd = keepGrainPolygons(gB,keepEnd);

surv = find(keepEnd);
if numel(surv) == nF, return; end

% -- each survivor swallows the run of segments before it ----------------
% chain ends always survive, so a run never crosses into another chain
runStart = [1; surv(1:end-1)+1];
FNew = [gB.F(runStart,1), gB.F(surv,2)];

gB = gB.subSet(surv);
gB.F = FNew;

% dissolving vertices does not touch the junctions, so the chains are the
% same ones - but F was written directly, so normalise it
gB = gB.order;

% the surviving junctions are the same ones, but triplePointList.boundaryId
% refers to segment ids and those were just renumbered
gB.triplePoints = gB.calcTriplePoints;

end
