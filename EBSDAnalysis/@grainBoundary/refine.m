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

% resample between the vertices that may not move, not only between the junctions
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

% every piece is a contiguous run, so one cumulative arc serves all of them
L = gB.segLength;
Lc = [0; cumsum(L)];

% sum the length of a piece on its own, round(total/delta) sits on a tie whenever
% a piece is a whole number of samples long - and force every repelem to a column
pieceOf = reshape(repelem((1:nCh).',iEnd-iStart+1),[],1);
total = accumarray(pieceOf,L,[nCh 1]);

% how many segments to split each piece into
m = max(1,round(total./delta));
M = sum(m);

% expand the pieces into the new segment list: cOf is the piece a new segment
% belongs to, kOf its one based position within that piece
cOf = reshape(repelem((1:nCh).',m),[],1);
mOf = m(cOf);
kOf = (1:M).' - reshape(repelem([0; cumsum(m(1:end-1))],m),[],1);

% the samples, in the same global arc coordinate
gStart = Lc(iStart);
tEnd = total(cOf).*kOf./mOf;
tPrev = total(cOf).*(kOf-1)./mOf;
gEnd = gStart(cOf) + tEnd;
gMid = gStart(cOf) + (tPrev + tEnd)/2;

% inherit the per segment data from whatever covers the new segment's midpoint
src = locate(gMid,Lc,iStart(cOf),iEnd(cOf));

% every new segment contributes its head vertex, except the last one of a piece
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

% count the segment starts below each sample by sorting, ties go to the samples
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
