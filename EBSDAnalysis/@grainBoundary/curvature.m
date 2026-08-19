function kappa = curvature(gB,n)
% signed curvature of a boundary segment
%
% Syntax
%   kappa = curvature(gB)
%   kappa = curvature(gB,2)
%
% Description
% The Menger curvature through the midpoints of a segment and its two
% neighbours within the same chain, smoothed along the chain afterwards.
%
% The sign is meaningful: segments are stored in walk order with the grain
% gB.grainId(:,1) on the left, so a positive curvature means the boundary
% bulges into gB.grainId(:,2) and a negative one that it bulges into
% gB.grainId(:,1).
%
% Which of the two grains ends up in the first column is not a property of
% the segment, it is the direction it is walked in. To read the curvature as
% convex or concave with respect to one specific grain, put that grain into
% the first column everywhere first
%
%   gB = grains(k).boundary;
%   gB = flip(gB, gB.grainId(:,2) == grains(k).id);
%
%
% Segments at the end of an open chain have no neighbour on one side and
% therefore no curvature - those are returned as NaN. A chain consisting of
% a single segment is NaN throughout. Closed chains wrap around and are
% defined everywhere.
%
% Input
%  gB - @grainBoundary
%   n - number of smoothing iterations along the chain (default 50)
%
% Output
%  kappa - 1/fitting radius in EBSD units
%
% See also
% grainBoundary/flip grainBoundary/chainId grainBoundary/arcLength

if nargin == 1, n = 50; end

nF = length(gB);
kappa = nan(nF,1);
if nF == 0, return; end

mp = gB.midPoint.xy;

% -- neighbours within the chain -----------------------------------------
% walk order makes these k-1 and k+1, so no segment adjacency matrix is
% needed at all
iStart = find(gB.isChainStart);
iEnd = find(gB.isChainEnd);
isClosedChain = gB.isClosed(iStart);

prev = (1:nF).' - 1;
next = (1:nF).' + 1;

% a closed chain has no end - it wraps onto itself
prev(iStart(isClosedChain)) = iEnd(isClosedChain);
next(iEnd(isClosedChain)) = iStart(isClosedChain);

hasPrev = true(nF,1); hasPrev(iStart(~isClosedChain)) = false;
hasNext = true(nF,1); hasNext(iEnd(~isClosedChain)) = false;

ok = hasPrev & hasNext;
if ~any(ok), return; end

% -- Menger curvature through the three midpoints ------------------------
mpC = mp(ok,:);
mpL = mp(prev(ok),:);
mpR = mp(next(ok),:);

% the cross product of (C-L) and (R-L) is positive for a left turn, which is
% a boundary curving away from the grain on its left
kappa(ok) = 2*(((mpC - mpL) .* fliplr(mpR - mpL)) * [1;-1]) ./ ...
  sqrt(sum((mpC-mpL).^2,2) .* sum((mpR-mpL).^2,2) .* sum((mpC-mpR).^2,2));

% -- smooth along the chain ----------------------------------------------
% clamping the neighbours at open chain ends keeps the smoothing inside its
% own chain and stops the undefined ends from spreading
if n > 0

  p = prev; p(~hasPrev) = find(~hasPrev);
  q = next; q(~hasNext) = find(~hasNext);

  k = kappa;
  k(~ok) = 0;

  for i = 1:n
    k = 0.25*k(p) + 0.5*k + 0.25*k(q);
  end

  kappa(ok) = k(ok);

end

end
