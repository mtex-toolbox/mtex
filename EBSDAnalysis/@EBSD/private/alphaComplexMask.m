function rMin = alphaComplexMask(pos, isIndexed, ij, epsilon, rAlpha, ...
  szP, padding, ijmin, ijsz, idealFun, reconstructPos, isIndexedP)
% true circumradius alpha-complex, rasterized onto the padded (i,j) grid as the
% smallest circumradius of a filled triangle covering each cell, inf where none
%
% The indexed sites are triangulated together with a dummy ring beyond any
% alpha-included triangle, so no Voronoi edge is left unbounded. A triangle with
% circumradius <= rAlpha is filled, i.e. the convex hull of its incident real
% sites is rasterized - for a cocircular group the hull of the whole group.

idxIdx = find(isIndexed);
idxPos = pos(idxIdx,:);
nIdx = numel(idxIdx);

% dummy ring along the padded raster's perimeter, beyond any alpha-included triangle
iRange = (ijmin(1)-padding):(ijmin(1)+ijsz(1)-1+padding);
jRange = (ijmin(2)-padding):(ijmin(2)+ijsz(2)-1+padding);
ringIJ = [ ...
  [iRange.', repmat(jRange(1),  numel(iRange),1)]; ...
  [iRange.', repmat(jRange(end),numel(iRange),1)]; ...
  [repmat(iRange(1),  numel(jRange),1), jRange.']; ...
  [repmat(iRange(end),numel(jRange),1), jRange.'] ];
bnd = idealFun(unique(ringIJ,'rows'));

XYa = [idxPos; bnd];
[Va,Fa,I_FDa] = jcvoronoi2(double(XYa), double(nIdx), double(epsilon));

nnzPerEdge = full(sum(I_FDa,2));
pureEdge   = nnzPerEdge == 2;             % real-real edges (no dummy site)

touchesDummy = false(size(Va,1),1);
impureRows = find(~pureEdge);
touchesDummy(Fa(impureRows,1)) = true;
touchesDummy(Fa(impureRows,2)) = true;
pureVertex = ~touchesDummy;

% (vertex,site) incidences from pure edges only: both endpoints of a
% real-real edge are equidistant from both its sites
[er,ec] = find(I_FDa);
k = pureEdge(er); er = er(k); ec = ec(k);
vtxAll  = [Fa(er,1); Fa(er,2)];
siteAll = [ec; ec];

keep = pureVertex(vtxAll);
vtxAll = vtxAll(keep); siteAll = siteAll(keep);

rMin = inf(prod(szP),1);
if isempty(vtxAll), return, end

% circumradius per pure vertex, via any one associated site (all incident
% real sites are equidistant from the vertex by construction)
[uVtx,~,ib] = unique(vtxAll);
firstIdx = accumarray(ib, (1:numel(ib))', [], @min);
repSite  = siteAll(firstIdx);
rad = vecnorm(Va(uVtx,:) - idxPos(repSite,:), 2, 2);

included = rad <= rAlpha + epsilon;
incVtx = uVtx(included);
if isempty(incVtx), return, end
radOf = zeros(size(Va,1),1); radOf(uVtx) = rad;

% full site group per included vertex (its triangle, or its cocircular
% group's convex hull), deduplicated
isIncVtxMask = false(size(Va,1),1);
isIncVtxMask(incVtx) = true;
keep2 = isIncVtxMask(vtxAll);
vsPairs = unique(vtxAll(keep2)*nIdx + siteAll(keep2) - 1);
vsPairs = [floor(vsPairs/nIdx) mod(vsPairs,nIdx) + 1];

[uV2,~,ig] = unique(vsPairs(:,1));
P = idxPos(vsPairs(:,2),:);
nS = accumarray(ig,1);

% only a group whose box holds a cell without a measurement can change rMin where it is read
rc = ij(idxIdx(vsPairs(:,2)),:) - ijmin + padding + 1;
lo = [accumarray(ig,rc(:,1),[],@min) accumarray(ig,rc(:,2),[],@min)] - 1;
hi = [accumarray(ig,rc(:,1),[],@max) accumarray(ig,rc(:,2),[],@max)] + 1;
S = zeros(szP+1); S(2:end,2:end) = cumsum(cumsum(reshape(~isIndexedP,szP),1),2);
cnt = @(r,c) S(r + (c-1)*(szP(1)+1));
g = find(nS >= 3 & cnt(hi(:,1)+1,hi(:,2)+1) - cnt(lo(:,1),hi(:,2)+1) ...
  - cnt(hi(:,1)+1,lo(:,2)) + cnt(lo(:,1),lo(:,2)) > 0);

% every group as a convex polygon, counterclockwise around its centroid
c = [accumarray(ig,P(:,1)) accumarray(ig,P(:,2))] ./ nS;
[~,o] = sortrows([ig, atan2(P(:,2)-c(ig,2), P(:,1)-c(ig,1))]);
P = P(o,:);
g1 = cumsum(nS) - nS + 1;
nxt = (2:numel(o)+1).'; nxt(g1 + nS - 1) = g1;

% the cells without a measurement in the box of every group, and which lie inside its polygon
n = prod(hi(g,:) - lo(g,:) + 1, 2);
gc = repelem(g,n);
q = (1:sum(n)).' - repelem(cumsum(n) - n,n) - 1;
nr = hi(gc,1) - lo(gc,1) + 1;
rc = lo(gc,:) + [mod(q,nr) floor(q./nr)];
u = ~isIndexedP(rc(:,1) + (rc(:,2)-1)*szP(1));
gc = gc(u); rc = rc(u,:);
xy = reconstructPos(rc - padding - 1 + ijmin);
m = nS(gc);
k = repelem((1:numel(gc)).',m);
e = repelem(g1(gc),m) + (1:sum(m)).' - repelem(cumsum(m) - m,m) - 1;
ev = P(nxt(e),:) - P(e,:);
tc = xy(k,:) - P(e,:);
bad = ev(:,1).*tc(:,2) - ev(:,2).*tc(:,1) < -epsilon*max(vecnorm(ev,2,2),epsilon);
in = accumarray(k,double(bad),[numel(gc) 1]) == 0;
rMin = min(rMin, accumarray(rc(in,1) + (rc(in,2)-1)*szP(1), radOf(uV2(gc(in))), ...
  [prod(szP) 1], @min, inf));

end
