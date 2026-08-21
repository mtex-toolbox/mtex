function dir = calcMeanDirection(gB,n)
% compute a smoothed direction that ignores staircasing
%
% Syntax
%   dir = calcMeanDirection(gB)
%   dir = calcMeanDirection(gB,2)
%
% Description
% This is very similar to direction with the only difference that it takes
% the direction across 2*n+1 segments instead of across a single one, which
% averages out the staircasing of a pixel grid. The window runs along the
% chain and is clamped at its ends, so it never smears across a junction.
%
% Input
%  gB - @grainBoundary
%  n  - number of neighboring segments considered on each side
%
% Output
%  dir - @vector3d
%
% See also
% grainBoundary/direction grainBoundary/chainId

if nargin == 1, n = 1; end

nF = length(gB);
if nF == 0, dir = vector3d; return; end

% -- the segments n steps back and forth along the chain -----------------
% walk order makes this plain arithmetic on the row index
iStart = find(gB.isChainStart);
iEnd = find(gB.isChainEnd);
isClosedChain = gB.isClosed(iStart);
cId = gB.chainId;

first = iStart(cId);            % first row of this segment's chain
last = iEnd(cId);               % last row of it
len = last - first + 1;

wraps = isClosedChain(cId);

% on a closed chain the window has to stay shorter than the chain, i.e. 2*n+1 <= len-1
nEff = repmat(n,nF,1);
nEff(wraps) = max(0,min(n,floor((len(wraps)-2)/2)));

back = (1:nF).' - nEff;
fwd = (1:nF).' + nEff;

% a closed chain wraps around, an open one is clamped at its ends
back(wraps) = first(wraps) + mod(back(wraps) - first(wraps),len(wraps));
fwd(wraps) = first(wraps) + mod(fwd(wraps) - first(wraps),len(wraps));
back(~wraps) = max(back(~wraps),first(~wraps));
fwd(~wraps) = min(fwd(~wraps),last(~wraps));

% same orientation as gB.direction, which runs from the head to the tail
dir = normalize(gB.allV(gB.F(back,1)) - gB.allV(gB.F(fwd,2)));
dir.antipodal = true;

end
