function gB = reduce(gB,factor)
% coarsen a list of grain boundary segments
%
% Syntax
%   gB_red = reduce(gB)
%   gB_red = reduce(gB,n)
%
% Description
% Dissolves every vertex that is not needed, keeping only every n-th one
% along each chain. Junctions are always kept, so the topology of the
% boundary network is preserved - which grains touch which, and where, is
% unchanged. This merges segments rather than dropping them, so the boundary
% stays connected and its total length is preserved up to the straightening
% of the removed corners.
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
% See also
% grainBoundary/simplify grainBoundary/order EBSD/reduce

if nargin == 1, factor = 2; end

nF = length(gB);
if nF == 0 || factor <= 1, return; end

% -- which end vertices survive ------------------------------------------
isEnd = gB.isChainEnd;
iStart = find(gB.isChainStart);
posInChain = (1:nF).' - iStart(gB.chainId);

% chain ends are junctions and always survive
keepEnd = isEnd | mod(posInChain+1,factor) == 0;

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

end
