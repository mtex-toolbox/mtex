function [gB,p] = order(gB,varargin)
% bring the boundary segments into walk order
%
% Syntax
%   gB = order(gB)
%   gB = order(gB,'leftPos',pos)
%   gB = order(gB,'leftPos',pos,'leftV',V)
%   [gB,p] = order(gB)
%
% Description
% Reorders the boundary segments such that consecutive segments of the same
% chain share a vertex, i.e. gB.F(k,2) == gB.F(k+1,1). A chain is a maximal
% run of segments joined at vertices where exactly two segments meet; a
% vertex where any other number of segments meet is a junction and always
% terminates a chain. Chains occupy contiguous blocks of rows.
%
% Each chain is additionally oriented such that the grain in gB.grainId(:,1)
% lies to the left of the walk direction. Which side that is cannot be
% derived from gB alone, so it has to be supplied via the leftPos option -
% one point per segment lying strictly on the grainId(:,1) side of it. For
% segments along the outer border, where grainId(:,1) is 0 and no such pixel
% exists, mirror the pixel of the other side through the segment midpoint.
% The side is read on the vertices leftV, one per vertex of gB.allV, which
% default to gB.allV. Without leftPos the walk order is still established, but the sense of each
% chain is arbitrary (deterministic, but not tied to grainId).
%
% Input
%  gB  - @grainBoundary
%  pos - @vector3d, one per segment, on the gB.grainId(:,1) side of it
%  V   - @vector3d, the vertices the side is read on
%
% Output
%  gB - @grainBoundary, in walk order
%  p  - the applied permutation, gB_ordered = gB_old.subSet(p)
%
% See also
% chainOrder grainBoundary.grainBoundary grainBoundary.grainBoundary grainBoundary.grainBoundary

F  = gB.F;
nF = size(F,1);
p  = (1:nF).';
if nF < 2, return; end

% -- decompose into chains and walk each of them -------------------------
% cid      - chain id of every segment
% pos      - its position along the walk, 0 based
% firstEnd - the column of F the walk enters the segment at
[cid,pos,firstEnd] = chainOrder(F,size(gB.allV,1));
nCh = max(cid);
len = accumarray(cid,1,[nCh 1]);   % segments per chain

% -- fix the sense of each chain so that grainId(:,1) is on the left ------
posLeft = get_option(varargin,'leftPos',[]);

if ~isempty(posLeft)

  % which side of every segment posLeft lies on, summed over the chain
  W = get_option(varargin,'leftV',gB.allV);
  Fw = F;
  Fw(firstEnd == 2,:) = fliplr(F(firstEnd == 2,:));
  V1 = W(Fw(:,1));
  flipCh = accumarray(cid,dot(cross(W(Fw(:,2)) - V1,posLeft - V1),gB.N),[nCh 1]) < 0;

else

  % without it keep the sense encoded in the column order of F, which makes order idempotent
  flipCh = accumarray(cid,double(firstEnd == 1),[nCh 1]) < 0.5*len;

end

ind = flipCh(cid);
if any(ind)
  pos(ind) = len(cid(ind)) - 1 - pos(ind);
  firstEnd(ind) = 3 - firstEnd(ind);
end

% -- apply ---------------------------------------------------------------
% cid is ascending in blocks and pos runs 0..len-1, so no sort is needed
chOff = cumsum([0;len]);
p(chOff(cid) + pos + 1) = (1:nF).';

doFlip = firstEnd == 2;
gB.F(doFlip,:) = fliplr(gB.F(doFlip,:));

% detach the triple points across the subSet, it would build the full I_VF
tP = gB.triplePoints;
detach = isa(tP,'triplePointList') && ~isempty(tP);
if detach, gB.triplePoints = struct('allV',tP.allV,'N',tP.N); end

gB = gB.subSet(p);

if detach, gB.triplePoints = tP; end

end
