function gB = refine(gB,varargin)
% subdivide each segment into pieces of about equal length
%
% Syntax
%   gB_r = refine(gB)
%   gB_r = refine(gB,delta)
%
% Description
% Splits every segment into round(segLength/delta) pieces of equal length.
% All existing vertices stay where they are and the new ones lie on the old
% segments, so the boundary keeps its shape and its length - only the
% sampling gets finer. Run after grain2d/simplifyBoundary, this turns the long
% chords of a coarsened boundary into the evenly spaced degrees of freedom
% grain2d/smoothBoundary needs.
%
% Walk order, grainId, phaseId, ebsdId and misrotation carry over from the
% segment a piece lies on.
%
% Input
%  gB    - @grainBoundary
%  delta - target segment length (default: half the median segment length)
%
% Output
%  gB_r - @grainBoundary
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

% how many pieces each segment is split into, src the segment of a piece and
% k its one based position within it
m = max(1,round(reshape(gB.segLength,[],1) ./ delta));
src = reshape(repelem((1:nF).',m),[],1);
c0 = cumsum(m) - m;
k = (1:numel(src)).' - c0(src);

% every piece but the last of a segment ends on a new vertex
isNew = k < m(src);
xyz = gB.allV.xyz;
P1 = xyz(gB.F(src(isNew),1),:);
P2 = xyz(gB.F(src(isNew),2),:);
lambda = k(isNew) ./ m(src(isNew));

head = gB.F(src,2);
head(isNew) = size(xyz,1) + (1:nnz(isNew)).';
tail = gB.F(src,1);
tail(k > 1) = head(find(k > 1) - 1);

gB = gB.subSet(src);
gB.allV = [gB.allV; vector3d.byXYZ(P1 + lambda.*(P2 - P1))];
gB.F = [tail, head];
gB.triplePoints = gB.calcTriplePoints;

end
