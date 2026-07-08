function grainId = absorbInteriorPixels(grains,ebsd,grainId)
% assign a grainId to pixels currently at 0 that lie entirely within one grain
%
% grainId 0 stays reserved for pixels a grain boundary passes through. Done in
% two steps:
%   1) floodCandidates - propose a candidate grain for each zero pixel cheaply,
%      by flooding grain labels outward over the grid (a fjord's deep pixels get
%      the flanking grain; medial-axis pixels get no candidate).
%   2) footprintInside - verify each candidate geometrically: the pixel's whole
%      unit-cell footprint (corners nudged slightly inward for stability) must
%      lie inside the candidate grain. A pixel a boundary crosses fails and
%      stays 0. This gates out the flood's boundary-subdivided assignments.
%
% Input
%  grains  - @grain2d
%  ebsd    - @EBSD (gridified)
%  grainId - nEbsd x 1 grain id per pixel (0 = unassigned)
%
% Output
%  grainId - updated grain id per pixel

ind0 = find(grainId == 0);
if isempty(ind0), return; end

cand   = floodCandidates(ebsd,grainId);      % candidate grain per pixel (0 = none)
c0     = cand(ind0);
sel    = c0 > 0;
rows   = ind0(sel);  gCand = c0(sel);
inside = footprintInside(grains,ebsd,rows,gCand);
grainId(rows(inside)) = gCand(inside);

end

% =========================================================================
function cand = floodCandidates(ebsd,grainId)
% Propose a candidate grain for every grainId==0 pixel by flooding the grain
% labels outward over the grid from all grain-bearing pixels (multi-source
% layered BFS). Each unassigned pixel is proposed the grain that reaches it
% first (shortest grid distance through the unassigned region); a pixel reached
% by two different grains at the same distance is on the medial axis and gets
% NO proposal (stays 0). This is only a candidate - footprintInside verifies it
% geometrically. Already grain-bearing pixels keep their id. Phase-agnostic:
% indexed and notIndexed grains flood alike.

[Agrid,stencil] = latticeBasis(ebsd.unitCell);
posE = [ebsd.pos.x(:), ebsd.pos.y(:)];
ijE  = round((posE - min(posE,[],1)) / Agrid');
nEb  = size(posE,1);
ijmin = min(ijE,[],1);  ijsz = max(ijE,[],1) - ijmin + 1;
slot  = @(IJ) (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
cell2e = zeros(prod(ijsz),1); cell2e(slot(ijE)) = 1:nEb;

% grid neighbour edges; the stencil is symmetric so both directions appear
P = []; Q = [];
for s = 1:size(stencil,1)
  nbIJ = ijE + stencil(s,:);
  inRange = all(nbIJ >= ijmin & nbIJ <= ijmin+ijsz-1, 2);
  src = find(inRange);  dst = cell2e(slot(nbIJ(src,:)));
  ok = dst > 0;
  P = [P; src(ok)]; Q = [Q; dst(ok)]; %#ok<AGROW>
end

cand    = grainId;                              % 0 = unassigned
visited = grainId > 0;
frontier = find(visited);
while ~isempty(frontier)
  isF = false(nEb,1); isF(frontier) = true;
  msk = isF(P) & ~visited(Q);                   % frontier -> unvisited neighbour
  qc = Q(msk);  prop = cand(P(msk));
  if isempty(qc), break; end
  gmin = accumarray(qc, prop, [nEb 1], @min, 0);
  gmax = accumarray(qc, prop, [nEb 1], @max, 0);
  newv = find(gmin > 0);
  single = gmin(newv) == gmax(newv);            % reached by exactly one grain
  cand(newv(single)) = gmin(newv(single));
  visited(newv) = true;                         % tie pixels visited, stay 0
  frontier = newv(single);                      % only proposed pixels propagate
end

end

% =========================================================================
function inside = footprintInside(grains,ebsd,rows,gCand)
% Verify, for each pixel in `rows` with candidate grain id gCand, that its whole
% unit-cell footprint lies inside that candidate grain. Corners are pulled
% slightly inward toward the pixel centre so they are not sitting exactly on the
% shared lattice boundary lines (where several grains meet), which makes the
% point-in-polygon test stable. Returns a logical per row: true iff every nudged
% corner is inside the candidate grain (holes excluded); pixels a grain boundary
% crosses fail and stay 0.
%
% Speed: the grain polygon coordinates are pulled out of grains.allV / grains.poly
% ONCE and fed to insidepoly as plain numeric arrays. There is no per-grain
% subscripting of the grain object (grains(...) / checkInside), which was the
% dominant cost. poly{k} is a single index loop into V that stitches any holes
% back to the outer ring (keyhole form), so insidepoly reports points in holes
% as outside automatically.

Vx = grains.allV.x;  Vy = grains.allV.y;
poly = grains.poly;                             % cell, one index loop per grain
gid  = grains.id(:);                            % grain id per poly cell

% map candidate grain id -> poly cell index
id2pos = zeros(max(gid),1); id2pos(gid) = 1:numel(gid);

nudge = 0.95;                                   % 1 = exact corner, <1 = inward
ucx = ebsd.unitCell.x(:);  ucy = ebsd.unitCell.y(:);
px  = ebsd.pos.x(:);       py  = ebsd.pos.y(:);
cx  = px(rows);            cy  = py(rows);

inside = false(numel(rows),1);
for gg = unique(gCand(:)).'
  sel = find(gCand == gg);
  pk  = poly{id2pos(gg)};                        % vertex-index loop of this grain
  Px  = Vx(pk);  Py = Vy(pk);
  allin = true(numel(sel),1);
  for k = 1:numel(ucx)
    qx = cx(sel) + nudge*ucx(k);                 % nudged corner k for these pixels
    qy = cy(sel) + nudge*ucy(k);
    allin = allin & insidepoly(qx, qy, Px, Py);
  end
  inside(sel) = allin;
end

end
