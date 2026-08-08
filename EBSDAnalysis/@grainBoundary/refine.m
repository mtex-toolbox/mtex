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
% whichever original segment covers the new segment's midpoint.
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

newF = cell(nCh,1);
newSrc = cell(nCh,1);
newV = cell(nCh,1);
nAdded = 0;

for c = 1:nCh

  s = (iStart(c):iEnd(c)).';

  % the vertices of the chain: the tail of every segment plus the last head
  v = [gB.F(s,1); gB.F(s(end),2)];
  P = xyz(v,:);

  segLen = sqrt(sum(diff(P,1,1).^2,2));
  arc = [0; cumsum(segLen)];
  total = arc(end);

  % how many segments to split the chain into
  m = max(1,round(total/delta));

  t = total*(0:m).'/m;

  % locate each sample on the original polyline and interpolate
  [iSeg,lambda] = locate(t,arc,segLen);
  Q = P(iSeg,:) + lambda.*(P(iSeg+1,:) - P(iSeg,:));

  % the junctions at both ends keep their vertex ids, so the triple points
  % and any other boundary meeting them stay attached
  ids = zeros(m+1,1);
  ids(1) = v(1);
  ids(end) = v(end);
  if m > 1
    ids(2:end-1) = nV0 + nAdded + (1:m-1).';
    newV{c} = Q(2:end-1,:);
    nAdded = nAdded + m - 1;
  else
    newV{c} = zeros(0,3);
  end

  newF{c} = [ids(1:end-1), ids(2:end)];

  % inherit the per segment data from whatever covered the new midpoint
  iMid = locate((t(1:end-1)+t(2:end))/2,arc,segLen);
  newSrc{c} = s(iMid);

end

F = vertcat(newF{:});
src = vertcat(newSrc{:});

gB = gB.subSet(src);
gB.allV = [gB.allV; vector3d.byXYZ(vertcat(newV{:}))];
gB.F = F;

gB = gB.order;
gB.triplePoints = gB.calcTriplePoints;

end

% -------------------------------------------------------------------------
function [iSeg,lambda] = locate(t,arc,segLen)
% which piece of the polyline does arc length t fall on, and how far along

n = numel(segLen);

% arc is non decreasing but may repeat if a segment has zero length, which
% discretize will not accept - histc style lookup handles it
iSeg = sum(t(:).' > arc(1:end-1),1).';
iSeg = min(max(iSeg,1),n);

if nargout > 1
  d = segLen(iSeg);
  lambda = zeros(size(iSeg));
  ok = d > 0;
  lambda(ok) = (t(ok) - arc(iSeg(ok))) ./ d(ok);
  lambda = min(max(lambda,0),1);
end

end
