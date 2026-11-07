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
% whether the unit-cell corners of every pixel rows, pulled slightly towards its centre, lie
% inside its candidate grain gCand (holes excluded), a point on the boundary counting as inside
%
% The rule of insidepoly: a vertical ray crossing segments counted on [x1,x2), on the boundary
% within 1e-9 of the grain's extent. A corner meets only the segments of its grain in its
% column of the unit-cell width.

% the segments of all grains, every loop closed onto its first vertex
poly = grains.poly; n = cellfun('length',poly(:));
ia = [poly{:}].';
ib = (2:numel(ia)+1).'; ib(cumsum(n)) = cumsum(n) - n + 1; ib = ia(ib);
gs = repelem((1:numel(n)).',n);
x1 = grains.allV.x(ia); y1 = grains.allV.y(ia);
x2 = grains.allV.x(ib); y2 = grains.allV.y(ib);

% on-boundary tolerance of every grain from its extent
bx = [accumarray(gs,x1,[],@min) accumarray(gs,x1,[],@max)];
by = [accumarray(gs,y1,[],@min) accumarray(gs,y1,[],@max)];
tol = max(1e-9*max(diff(bx,1,2),diff(by,1,2)),8*eps*max(abs([bx by]),[],2));
tol = tol(gs);

% per segment: its x bracket, a, the band c in (bLo,bHi) of points on it, a vertical one by box
dx = x2 - x1; dy = y2 - y1; v = dx == 0;
xLo = min(x1,x2); xHi = max(x1,x2);
a = x1.*y2 - x2.*y1;
b = x1.*dy - y1.*dx; t = sqrt(dx.^2 + dy.^2).*tol;
bLo = b - t; bHi = b + t; bLo(v) = -inf; bHi(v) = inf;
oxLo = xLo; oxHi = xHi; oxLo(v) = x1(v) - tol(v); oxHi(v) = x1(v) + tol(v);
oyLo = -inf(size(v)); oyHi = -oyLo; oyLo(v) = min(y1(v),y2(v)); oyHi(v) = max(y1(v),y2(v));

% every segment into each column its on-boundary x bracket meets, keyed by grain and column
w = max(ebsd.unitCell.x) - min(ebsd.unitCell.x);
col = @(x) floor((x - min(ebsd.pos.x(:)))/w);
c1 = col(oxLo); r = col(oxHi) - c1 + 1; c0 = min(c1); nc = max(c1 + r) - c0;
m = repelem((1:numel(ia)).',r);
[key,o] = sort(gs(m)*nc + (1:numel(m)).' - repelem(cumsum(r) - r + 1 - c1 + c0,r));
m = m(o);
[uk,first] = unique(key,'first');
cnt = diff([first;numel(key)+1]);

% the nudged corners and their buckets
id2pos = zeros(max(grains.id),1); id2pos(grains.id) = 1:numel(n);
qx = ebsd.pos.x(rows(:)) + 0.95*ebsd.unitCell.x(:).'; qx = qx(:);
qy = ebsd.pos.y(rows(:)) + 0.95*ebsd.unitCell.y(:).'; qy = qy(:);
[hit,loc] = ismember(repmat(id2pos(gCand(:)),numel(ebsd.unitCell.x),1)*nc + col(qx) - c0,uk);

% the parity of the crossings, then the boundary band for the corners left outside, in chunks
odd = false(size(qx)); on = odd;
qi = find(hit); nP = cnt(loc(qi)); cs = [0;cumsum(nP)];
k0 = 1;
while k0 <= numel(qi)
  k = (k0:max(k0,find(cs <= cs(k0) + 4e6,1,'last') - 1)).';
  p = repelem(qi(k),nP(k));
  e = m((1:numel(p)).' + repelem(first(loc(qi(k))) - 1 - cs(k) + cs(k0),nP(k)));
  c = qx(p).*dy(e) - qy(p).*dx(e);
  odd = xor(odd,logical(mod(accumarray(p,qx(p) >= xLo(e) & qx(p) < xHi(e) & ...
    sign(dx(e)).*(c - a(e)) >= 0,size(qx)),2)));
  s = ~odd(p); p = p(s); e = e(s); c = c(s);
  on = on | accumarray(p,qx(p) >= oxLo(e) & qx(p) <= oxHi(e) & qy(p) >= oyLo(e) & ...
    qy(p) <= oyHi(e) & c > bLo(e) & c < bHi(e),size(qx)) > 0;
  k0 = k(end) + 1;
end

inside = all(reshape(odd | on,numel(rows),[]),2);

end
