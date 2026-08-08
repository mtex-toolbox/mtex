function gB = refine(gB,varargin)
% resample each chain at a constant spacing along its length
%
% Syntax
%   gB_r = refine(gB)
%   gB_r = refine(gB,delta)
%   gB_r = refine(gB,delta,'protect',vertexIds)
%
% Description
% Places new vertices at equal arc length along each chain, between the
% vertices that have to survive, which stay exactly where they are. The new
% vertices lie on the old boundary, so this changes nothing about its shape -
% it only changes how it is sampled.
%
% A chain is cut into pieces that are resampled independently at every vertex
% that may not move: its two junctions, a vertex where the neighbouring grains
% change, and anything passed in as 'protect'. A chain resampled in one piece
% visits none of the ones in between, which leaves the inner boundary hanging
% off a vertex the outer walk no longer reaches, and lets a segment carry the
% grainId pair of its neighbour.
%
% This is what makes a subsequent grain2d/smoothBoundary work properly.
% Subdividing each segment, as grain2d/refineBoundary used to do on its own,
% preserves the staircase of the pixel grid and only makes it finer.
% Resampling at equal arc length instead gives the smoothing evenly spaced
% degrees of freedom that are not tied to the grid.
%
% grainId and phaseId are constant along a chain and carry over exactly.
% ebsdId and misrotation belong to a specific pair of pixels, which a
% resampled segment no longer corresponds to - those are inherited from
% whichever original segment covers the new segment's midpoint. A midpoint
% landing on the seam between two of them is covered by both, and which one it
% takes is then decided by the last bits of the arc length.
%
% Input
%  gB    - @grainBoundary
%  delta - target segment length (default: half the median segment length -
%          a sample every median length may cut a corner per sample where the
%          segments are not all of the same length, half of it follows the
%          original polyline closely)
%
% Output
%  gB_r - @grainBoundary
%
% Options
%  protect - ids of vertices that must survive, on top of the junctions
%
% See also
% grainBoundary/simplify grainBoundary/reduce grain2d/refineBoundary grain2d/smoothBoundary

nF = length(gB);
if nF == 0, return; end

if ~isempty(varargin) && isnumeric(varargin{1}) && isscalar(varargin{1})
  delta = varargin{1};
else
  delta = median(gB.segLength) / 2;
end
if delta <= 0, return; end

xyz = gB.allV.xyz;
nV0 = size(xyz,1);

% resample between the vertices that may not move, not merely between the two
% junctions of a chain - a vertex where the neighbouring grains change is a
% corner of both grain polygons, and grain2d passes in the ones shared with the
% inner boundary, which finds its junctions from its own face list and so
% cannot see them (see grain2d/refineBoundary)
isEnd = gB.isChainEnd | isNeighborChange(gB);

protect = get_option(varargin,'protect',[]);
if ~isempty(protect)
  isProtected = false(size(gB.allV,1),1);
  isProtected(protect) = true;
  isEnd = isEnd | isProtected(gB.F(:,2));
end

iEnd = find(isEnd);
iStart = [1; iEnd(1:end-1)+1];
nCh = numel(iStart);

% Every piece is a contiguous run of segments, so one cumulative arc over the
% whole segment list serves all of them at once - the arc within a piece is the
% global one minus the value at its start. That is what lets the resampling run
% over all pieces together instead of one chain at a time.
L = gB.segLength;
Lc = [0; cumsum(L)];

% The length of a piece is summed on its own rather than read off Lc as a
% difference of two large numbers. round(total/delta) sits exactly on a tie
% whenever a piece is a whole number of samples long, which on a regular grid
% is most of them, so the last bits of total decide how many samples it gets.
pieceOf = repelem((1:nCh).',iEnd-iStart+1);
total = accumarray(pieceOf,L,[nCh 1]);

% how many segments to split each piece into
m = max(1,round(total./delta));
M = sum(m);

% expand the pieces into the new segment list: cOf is the piece a new segment
% belongs to, kOf its one based position within that piece
cOf = repelem((1:nCh).',m);
mOf = m(cOf);
kOf = (1:M).' - repelem([0; cumsum(m(1:end-1))],m);

% the samples, in the same global arc coordinate. The midpoint is the mean of
% the two ends rather than (k-1/2)/m - the same number in exact arithmetic, but
% this is the form the per chain version used and the two do not round alike
gStart = Lc(iStart);
tEnd = total(cOf).*kOf./mOf;
tPrev = total(cOf).*(kOf-1)./mOf;
gEnd = gStart(cOf) + tEnd;
gMid = gStart(cOf) + (tPrev + tEnd)/2;

% inherit the per segment data from whatever covers the new segment's midpoint
src = locate(gMid,Lc,iStart(cOf),iEnd(cOf));

% Every new segment contributes its head vertex, except the last one of a
% piece, whose head is the junction the piece ends on and already exists. The
% junctions at both ends of a piece keep their vertex ids, so the triple points
% and any other boundary meeting them stay attached.
isLast = kOf == mOf;
isNew = ~isLast;

[iSeg,lambda] = locate(gEnd(isNew),Lc,iStart(cOf(isNew)),iEnd(cOf(isNew)));
P1 = xyz(gB.F(iSeg,1),:);
P2 = xyz(gB.F(iSeg,2),:);
Q = P1 + lambda.*(P2 - P1);

head = zeros(M,1);
head(isNew) = nV0 + (1:nnz(isNew)).';
head(isLast) = gB.F(iEnd(cOf(isLast)),2);

% within a piece the tail of a segment is the head of the one before it
tail = zeros(M,1);
isFirst = kOf == 1;
tail(isFirst) = gB.F(iStart(cOf(isFirst)),1);
tail(~isFirst) = head(find(~isFirst)-1);

gB = gB.subSet(src);
gB.allV = [gB.allV; vector3d.byXYZ(Q)];
gB.F = [tail, head];

gB = gB.order;
gB.triplePoints = gB.calcTriplePoints;

end

% -------------------------------------------------------------------------
function [iSeg,lambda] = locate(g,Lc,lo,hi)
% which segment does the arc length g fall on, and how far along it
%
% g is measured on the cumulative arc Lc of the whole segment list; lo and hi
% confine the answer to the piece the sample belongs to. A sample sitting
% exactly on a segment start belongs to that segment, not to the one before -
% so a zero length segment never swallows a sample.

nE = numel(Lc) - 1;
n = numel(g);

% Count the segment starts strictly below each sample. Sorting the samples and
% the starts together costs (n+nE)log(n+nE), where comparing them pairwise
% costs n*nE - and MATLAB sorts stably, so putting the samples first in the
% concatenation is what breaks the ties in their favour.
[~,ord] = sort([g(:); Lc(1:nE)]);
isEdge = ord > n;
cnt = cumsum(isEdge);

iSeg = zeros(n,1);
iSeg(ord(~isEdge)) = cnt(~isEdge);

iSeg = min(max(iSeg,lo),hi);

if nargout > 1
  d = Lc(iSeg+1) - Lc(iSeg);
  lambda = zeros(n,1);
  ok = d > 0;
  lambda(ok) = (g(ok) - Lc(iSeg(ok))) ./ d(ok);
  lambda = min(max(lambda,0),1);
end

end
