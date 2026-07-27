function [gB,p] = order(gB,varargin)
% bring the boundary segments into walk order
%
% Syntax
%   gB = order(gB)
%   gB = order(gB,'leftPos',pos)
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
% Without leftPos the walk order is still established, but the sense of each
% chain is arbitrary (deterministic, but not tied to grainId).
%
% Input
%  gB  - @grainBoundary
%  pos - @vector3d, one per segment, on the gB.grainId(:,1) side of it
%
% Output
%  gB - @grainBoundary, in walk order
%  p  - the applied permutation, gB_ordered = gB_old.subSet(p)
%
% See also
% grainBoundary/chainId grainBoundary/chainV grainBoundary/junctionId

F  = gB.F;
nF = size(F,1);
p  = (1:nF).';
if nF < 2, return; end

Fv = F(:);                      % half edge h indexes the entry Fv(h) of F
nV = size(gB.allV,1);

deg   = accumarray(Fv,1,[nV 1]);
isJct = deg ~= 2;

% -- pair up the two half edges meeting at every degree 2 vertex ----------
% half edge h = k + (e-1)*nF reads "segment k entered at vertex F(k,e)"
[~,hs] = sort(Fv);              % half edges grouped by vertex
off    = [0; cumsum(deg)];      % vertex v owns hs(off(v)+1 : off(v)+deg(v))

partner = zeros(2*nF,1);
v2 = find(deg == 2);
h1 = hs(off(v2)+1);
h2 = hs(off(v2)+2);
partner(h1) = h2;
partner(h2) = h1;

% -- label the chains ----------------------------------------------------
k1  = mod(h1-1,nF)+1;
k2  = mod(h2-1,nF)+1;
cid = connectedComponents(sparse([k1;k2],[k2;k1],1,nF,nF));
cid = cid(:);
nCh = max(cid);

% -- closed chains have no junction, so cut them at their lowest vertex ---
hCid   = [cid;cid];
isOpen = accumarray(cid,double(isJct(F(:,1)) | isJct(F(:,2))),[nCh 1],@max) > 0;
if ~all(isOpen)
  onClosed = ~isOpen(hCid);
  vMin = accumarray(hCid(onClosed),Fv(onClosed),[nCh 1],@min,0);
  cutV = vMin(~isOpen);
  partner(hs(off(cutV)+1)) = 0;
  partner(hs(off(cutV)+2)) = 0;
end

% -- walk: entering a segment at one end means leaving it at the other ----
oth = [nF+1:2*nF, 1:nF].';
nxt = partner(oth);             % 0 where the chain terminates

% -- list ranking by pointer doubling: d(h) = segments left after h -------
isEnd    = nxt == 0;
f        = nxt;
f(isEnd) = find(isEnd);         % terminal half edges point to themselves
d        = double(~isEnd);
while true
  fNew = f(f);
  if isequal(fNew,f), break; end
  d = d + d(f);
  f = fNew;
end

% -- one start half edge per chain ---------------------------------------
% every open chain has two, one per direction; pick the lower for a
% deterministic result
startH = find(partner == 0);
[~,iFirst] = unique(hCid(startH),'stable');
startH = startH(iFirst);
chStart = zeros(nCh,1);
chStart(hCid(startH)) = startH;

% f(h) is the terminal of h's walk and so tells which of the two directions
% a half edge belongs to
onWalk = f == f(chStart(hCid));

seg  = repmat((1:nF).',2,1);
eIdx = repelem([1;2],nF,1);

pos = zeros(nF,1);
pos(seg(onWalk)) = d(chStart(hCid(onWalk))) - d(onWalk);
firstEnd = zeros(nF,1);
firstEnd(seg(onWalk)) = eIdx(onWalk);

% -- fix the sense of each chain so that grainId(:,1) is on the left ------
posLeft = get_option(varargin,'leftPos',[]);

if ~isempty(posLeft)

  rep = find(pos == 0);                   % first segment of every chain
  Fr  = F(rep,:);
  Fr(firstEnd(rep) == 2,:) = fliplr(Fr(firstEnd(rep) == 2,:));

  dir = gB.allV(Fr(:,2)) - gB.allV(Fr(:,1));
  w   = posLeft(rep) - 0.5*(gB.allV(Fr(:,1)) + gB.allV(Fr(:,2)));

  flipCh = false(nCh,1);
  flipCh(cid(rep)) = dot(cross(dir,w),gB.N) < 0;

else

  % without that information keep the sense already encoded in the column
  % order of F. On an already ordered boundary every segment of a chain
  % agrees, so this recovers the sense exactly and makes order idempotent -
  % which is what lets cat, subsasgn and loadobj re-establish the invariant
  % without scrambling the left/right convention.
  flipCh = accumarray(cid,double(firstEnd == 1),[nCh 1]) < ...
    0.5*accumarray(cid,1,[nCh 1]);

end

ind = flipCh(cid);
if any(ind)
  chMax = accumarray(cid,pos,[nCh 1],@max);
  pos(ind) = chMax(cid(ind)) - pos(ind);
  firstEnd(ind) = 3 - firstEnd(ind);
end

% -- apply ---------------------------------------------------------------
[~,p] = sortrows([cid pos]);
doFlip = firstEnd == 2;
gB.F(doFlip,:) = fliplr(gB.F(doFlip,:));
gB = gB.subSet(p);

end
