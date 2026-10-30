function grainId = absorbInteriorPixels(grains,ebsd,grainId)
% assign a grainId to pixels currently at 0 that lie entirely within one grain
%
% grainId 0 stays reserved for pixels a grain boundary passes through. Done in
% two steps:
%   1) nearestCandidates - propose for each zero pixel the grain of the nearest
%      pixel that has one, also across gaps in a sparse map.
%   2) footprintInside - verify each candidate geometrically: the pixel's whole
%      unit-cell footprint (corners nudged slightly inward for stability) must
%      lie inside the candidate grain. A pixel a boundary crosses fails and
%      stays 0. This gates out candidates from across a boundary.
%
% Input
%  grains  - @grain2d
%  ebsd    - @EBSD
%  grainId - nEbsd × 1 grain id per pixel (0 = unassigned)
%
% Output
%  grainId - updated grain id per pixel

ind0 = find(grainId == 0);
if isempty(ind0), return; end

cand   = nearestCandidates(ebsd,grainId);    % candidate grain per pixel (0 = none)
c0     = cand(ind0);
sel    = c0 > 0;
rows   = ind0(sel);  gCand = c0(sel);
inside = footprintInside(grains,ebsd,rows,gCand);
grainId(rows(inside)) = gCand(inside);

end

% =========================================================================
function cand = nearestCandidates(ebsd,grainId)
% propose for every grainId==0 pixel the grain of the nearest pixel that has one

cand = grainId;
has = find(grainId > 0);
ind0 = find(grainId == 0);
if numel(has) < 3, return; end
xy = [ebsd.pos.x(:), ebsd.pos.y(:)];
cand(ind0) = grainId(has(nearestId(xy(has,:),xy(ind0,:))));

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
