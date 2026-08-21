function [cid,pos,firstEnd] = chainOrder(F,nV,varargin)
% decompose an undirected edge list into maximal chains and walk each of them
%
% Syntax
%   [cid,pos,firstEnd] = chainOrder(F,nV)
%   [cid,pos,firstEnd] = chainOrder(F,nV,'noMex')
%
% Description
% A chain is a maximal run of edges joined at vertices where exactly two
% edges meet; a vertex of any other degree is a junction and terminates a
% chain. Every chain is walked from one end to the other, which assigns each
% edge a position within its chain and tells at which of its two vertices
% the walk enters it.
%
% Chains are numbered by increasing highest member edge index, and each is
% walked from its lower terminal half edge; a closed chain has no terminal
% and is cut at its lowest vertex. These tie breaks make the result unique,
% which is what lets the compiled and the MATLAB path be interchangeable.
%
% Input
%  F  - nF x 2 list of edges, one based vertex indices
%  nV - number of vertices
%
% Output
%  cid      - nF x 1 chain id, 1..nCh
%  pos      - nF x 1 zero based position of the edge within its chain
%  firstEnd - nF x 1, 1 or 2 - the column of F holding the entry vertex
%
% Flags
%  noMex - use the MATLAB implementation even if chainOrderC is available
%
% See also
% grainBoundary/order connectedComponents

persistent hasMex

nF = size(F,1);

if isempty(hasMex), hasMex = exist('chainOrderC','file') == 3; end

if hasMex && ~check_option(varargin,'noMex')
  [cid,pos,firstEnd] = chainOrderC(double(F),double(nV));
  return
end

if nF == 0
  [cid,pos,firstEnd] = deal(zeros(0,1));
  return
end

% -- pair up the two half edges meeting at every degree 2 vertex ----------
% half edge h = k + (e-1)*nF reads "edge k entered at vertex F(k,e)"
Fv = F(:);

deg   = accumarray(Fv,1,[nV 1]);
isJct = deg ~= 2;

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

% -- walk: entering an edge at one end means leaving it at the other ------
oth = [nF+1:2*nF, 1:nF].';
nxt = partner(oth);             % 0 where the chain terminates

% -- list ranking by pointer doubling: d(h) = edges left after h ----------
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
% an open chain has one per direction, pick the lower for a deterministic result
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

end
