function [V,F,I_FD,V0] = straightenInFill(V,F,I_FD,grainId,out)
% the shortest grain boundaries through the cells the alpha closing filled
%
% Syntax
%   [V,F,I_FD,V0] = straightenInFill(V,F,I_FD,grainId,out)
%
% Description
% Through filled cells a grain boundary follows the bisectors between the
% measured pixels around them, which bends it around the middle of a crack
% or a cluster of notIndexed pixels. Inside the filled cells the boundaries
% form a network: chains of segments between the junctions and the points
% where a boundary enters the fill. It is replaced by the shortest network
% of the same chains that passes every measured, unfilled and exterior cell
% on the same side, as for an isotropic boundary energy: every chain is
% pulled taut, so it is straight between the cell corners it bends around,
% and every junction sits where the sum of the distances to the first bends
% of its chains is least, which makes its chains meet at 120 degrees unless
% a cell is in the way. A region of filled cells at least half of which lie
% in a gap one cell wide between measured pixels of two grains is a boundary
% the measurement missed, as where the beam spans two grains; it keeps its
% bisectors. Every measured pixel stays in its grain, no boundary crosses
% another one, and the outer boundary never leaves the closing.
%
% Input
%  V,F,I_FD - vertices, segments and segment × pixel incidence
%  grainId  - grain of every pixel
%  out      - output of spatialDecompositionGrid
%
% Output
%  V,F,I_FD - with the boundary segments split where they enter the filled cells
%  V0       - the vertices before they moved, every segment on the bisector of its pixels

out = missedBoundaries(out,grainId);
inFill = out.inFill;
V0 = V;
if isempty(inFill), return; end

% segments between two grains or at the outer boundary
[f,d] = find(I_FD);
nF = size(F,1);
isB = accumarray(f,grainId(d),[nF 1],@min) ~= accumarray(f,grainId(d),[nF 1],@max) | ...
  accumarray(f,1,[nF 1]) == 1;

% a boundary segment gets a vertex where it enters the filled cells, twice, so the pieces are cut again
tol = out.epsilon;
look = isB;
for pass = 1:2
  look = find(look);
  dE = reshape(inFill(V(F(look,:),:)),[],2);
  isC = max(dE,[],2) > tol & min(dE,[],2) < -tol;
  k = ~isC & max(dE,[],2) > tol;
  [c2,a2,b2] = fillEntry(V,F,look(k),dE(k,:),inFill,tol,out.dxy);
  cut = [look(isC); c2];
  a = [V(F(look(isC),1),:); a2]; b = [V(F(look(isC),2),:); b2];
  lo = zeros(numel(cut),1); hi = ones(numel(cut),1);
  aIn = inFill(a) > 0;
  for it = 1:16
    mid = (lo + hi) / 2;
    isA = (inFill(a + mid .* (b - a)) > 0) == aIn;
    lo(isA) = mid(isA); hi(~isA) = mid(~isA);
  end
  nV = size(V,1); nF = size(F,1);
  V = [V; a + (lo + hi) / 2 .* (b - a)]; %#ok<AGROW>
  F = [F; nV + (1:numel(cut)).', F(cut,2)]; %#ok<AGROW>
  F(cut,2) = nV + (1:numel(cut)).';
  if pass > 1, [f,d] = find(I_FD); end
  r = zeros(nF,1); r(cut) = nF + (1:numel(cut)); s = r(f) > 0;
  I_FD = sparse([f; r(f(s))], [d; d(s)], 1, nF + numel(cut), size(I_FD,2));
  isB = [isB; true(numel(cut),1)]; %#ok<AGROW>
  look = false(size(F,1),1); look([cut; nF + (1:numel(cut)).']) = true;
end
V0 = V;

% the boundary segments with an end inside the fill; a vertex there with two of them is an inner
% vertex of a chain, every other one a node
G = fillGeometry(out);
segId = find(isB);
e = F(segId,:);
nV = size(V,1);
vB = unique(e);
isFree = false(nV,1); isFree(vB) = inFill(V(vB,:)) > tol;
keep = any(isFree(e),2);
e = e(keep,:); segId = segId(keep);
m = size(e,1);
deg = accumarray(e(:),1,[nV 1]);
isInner = isFree & deg == 2;

% a cycle of inner vertices gets a node, its first vertex
ii = all(isInner(e),2);
lab = conncomp(graph(e(ii,1),e(ii,2),[],nV)).';
atNode = false(nV,1); atNode(lab(e(~ii,:))) = true;
cyc = find(isInner & ~atNode(lab));
[~,f] = unique(lab(cyc));
isInner(cyc(f)) = false;
isNode = deg > 0 & ~isInner;

% lattice coordinates, the nodes on the fill edge exactly on the cell corner next to them
U = G.toU(V);
for k = 1:size(G.C,1)
  r = round(U - G.C(k,:)) + G.C(k,:);
  s = all(abs(U - r) < 0.1,2) & ~isFree;
  U(s,:) = r(s,:);
end

% the two segments of every inner vertex
[vv,o] = sort(e(:));
eid = [1:m 1:m].'; eid = eid(o);
ve = zeros(nV,2);
s = find(isInner(vv));
ve(vv(s) + nV * mod((1:numel(s)).' - 1,2)) = eid(s);

% walk from every node along every segment to the next node
[ws,wc] = find(isNode(e));
cur = e(ws + m*(2 - wc));
edg = ws;
act = (1:numel(ws)).';
rw = {zeros(0,1)}; rv = rw;
while ~isempty(act)
  act = act(~isNode(cur(act)));
  rw{end+1} = act; rv{end+1} = cur(act); %#ok<AGROW>
  t = ve(cur(act),:);
  ne = t(:,1); s = ne == edg(act); ne(s) = t(s,2);
  cur(act) = e(ne,1) + e(ne,2) - cur(act);
  edg(act) = ne;
end
rw = vertcat(rw{:}); rv = vertcat(rv{:});

% every chain once, as walked from the smaller of its two end segments: start and end node, last
% segment, and the inner vertices iv in order with their chain ic
hs = ws + m*(wc - 1);
he = edg + m*(e(edg,2) == cur);
isC = hs < he;
ch = cumsum(isC);
C = nnz(isC);
cS = e(hs(isC)); cE = cur(isC); cLast = segId(edg(isC));
s = find(isC(rw));
[ic,o] = sort(ch(rw(s)));
iv = rv(s(o));
nI = accumarray(ic,1,[C 1]);

% the points of the polylines: the inner vertices, then a start and an end point for every chain,
% nb the point before and after
sS = nV + (1:C).'; sE = nV + C + (1:C).';
nP = nV + 2*C;
X = [U; U(cS,:); U(cE,:)];
nb = zeros(nP,2);
first = diff([0; ic]) > 0; last = diff([ic; inf]) > 0;
nb(iv,1) = iv([end 1:end-1]); nb(iv(first),1) = sS(ic(first));
nb(iv,2) = iv([2:end 1]); nb(iv(last),2) = sE(ic(last));
nb(sS,2) = sE; nb(sS(ic(first)),2) = iv(first);
nb(sE,1) = sS; nb(sE(ic(last)),1) = iv(last);
dirty = false(nP,1); dirty(iv) = true;

% the junctions J, the free nodes, and the chain ends sJ at junction jS
J = find(isNode & isFree);
jOf = zeros(nV,1); jOf(J) = 1:numel(J);
sJ = [sS(jOf(cS) > 0); sE(jOf(cE) > 0)];
jS = jOf([cS(jOf(cS) > 0); cE(jOf(cE) > 0)]);
isStart = (1:numel(sJ)).' <= nnz(jOf(cS));
jOf = zeros(nP,1); jOf(sJ) = jS;
Xj = U(J,:);
nJ = numel(J);

[X,nb,dirty,nP] = tighten(X,nb,dirty,nP,G);

L = inf;
for it = 1:11
  if isempty(J), break; end
  jOf(end+1:size(X,1)) = 0;
  f = sum(nb(sJ,:),2);
  len = vecnorm((X(sJ,:) - X(f,:)) * G.M,2,2);
  jf = jOf(f);
  a = find(nb(:,2));
  L(it+1) = sum(vecnorm((X(a,:) - X(nb(a,2),:)) * G.M,2,2)); %#ok<AGROW>
  isLast = it > 10 || L(it) - L(it+1) < 5e-4 * L(it+1);
  if ~isLast

    % the junctions with the least sum of squared lengths, each weighted by the inverse of the present length
    w = 1 ./ sqrt(len.^2 + (1e-3 * out.dxy)^2);
    A = sparse(jS,jS,w,nJ,nJ) - sparse(jS(jf > 0),jf(jf > 0),w(jf > 0),nJ,nJ);
    b = [accumarray(jS(~jf),w(~jf) .* X(f(~jf),1),[nJ 1]), accumarray(jS(~jf),w(~jf) .* X(f(~jf),2),[nJ 1])];
    d = (A + 1e-9 * speye(nJ)) \ (b + 1e-9 * Xj) - Xj;
    d(vecnorm(d,2,2) < 1e-2,:) = 0;
  else

    % at last junctions a tenth of a pixel apart become one point
    a = jf > 0 & len < 0.1 * out.dxy;
    lab = conncomp(graph(jS(a),jf(a),[],nJ)).';
    d = [accumarray(lab,Xj(:,1),[],@mean), accumarray(lab,Xj(:,2),[],@mean)];
    d = d(lab,:) - Xj;
  end

  % as far as the fill reaches, along the side of a cell where that blocks
  dn = clipStep(Xj,d,G) .* d;
  k = find(vecnorm(dn,2,2) < 1e-6 & vecnorm(d,2,2) > 1e-6);
  for a = 1:size(G.side,1)
    da = (d(k,:) * G.side(a,:).') .* G.side(a,:) / sum(G.side(a,:).^2);
    da = clipStep(Xj(k,:),da,G) .* da;
    s = vecnorm(da,2,2) > vecnorm(dn(k,:),2,2);
    dn(k(s),:) = da(s,:);
  end
  dn(vecnorm(dn,2,2) < 1e-9,:) = 0;
  Y = Xj + dn;

  % the old place stays as a point of every chain whose end sweeps over a cell that is no fill
  mvd = any(dn(jS,:),2);
  for st = [true false]
    a = find(mvd & isStart == st);
    f = sum(nb(sJ(a),:),2);
    Yf = X(f,:); Yf(jOf(f) > 0,:) = Y(nonzeros(jOf(f)),:);
    lo = min(min(min(Y(jS(a),:),Xj(jS(a),:)),X(f,:)),Yf);
    hi = max(max(max(Y(jS(a),:),Xj(jS(a),:)),X(f,:)),Yf);
    s = anyObst(lo,hi,G);
    a = a(s); f = f(s);
    c = nP + (1:numel(a)).';
    nP = nP + numel(a);
    [X,nb,dirty] = room(X,nb,dirty,nP);
    jOf(end+1:size(X,1)) = 0;
    X(c,:) = Xj(jS(a),:);
    dirty(c) = true;
    nb(c,:) = [sJ(a) f];
    nb(c,:) = nb(c,[2-st 1+st]);
    nb(sJ(a),1+st) = c; nb(f,2-st) = c;
  end

  % the first point of every chain of a moved junction is looked at again
  f = sum(nb(sJ(mvd),:),2);
  dirty(f(all(nb(f,:),2))) = true;
  X(sJ,:) = Y(jS,:);
  Xj = Y;
  [X,nb,dirty,nP] = tighten(X,nb,dirty,nP,G);
  if isLast, break; end
end

% the bends ib of every chain in order, cb their chain
cur = nb(sS,2);
act = find(cur ~= sE);
cb = {zeros(0,1)}; ib = cb;
while ~isempty(act)
  cb{end+1} = act; ib{end+1} = cur(act); %#ok<AGROW>
  cur(act) = nb(cur(act),2);
  act = act(cur(act) ~= sE(act));
end
[cb,o] = sort(vertcat(cb{:}));
ib = vertcat(ib{:}); ib = ib(o);
nB = accumarray(cb,1,[C 1]);

% a chain with more bends than inner vertices gets the missing ones on its last segment
r = max(nB - nI,0);
other = F(cLast,1) + F(cLast,2) - cE;
g = repelem((1:C).',r,1);
i = (1:sum(r)).' - repelem(cumsum(r) - r,r,1);
w = size(V,1) + (1:sum(r)).';
t = i ./ (r(g) + 1);
V0 = [V0; (1 - t) .* V0(other(g),:) + t .* V0(cE(g),:)];
V = [V; V0(w,:)];
isL = F(cLast,2) == cE;
Fn = [w, w + 1]; Fn(i == r(g),2) = cE(g(i == r(g)));
Fp = [w, w - 1]; Fp(i == 1,2) = other(g(i == 1));
Fn(~isL(g),:) = Fp(~isL(g),:);
F(cLast(isL & r > 0),2) = w(i == 1 & isL(g));
F(cLast(~isL & r > 0),2) = w(i == r(g) & ~isL(g));
F = [F; Fn];
IT = I_FD.';
I_FD = [I_FD; IT(:,cLast(g)).'];
[ic,o] = sort([ic; g]);
iv = [iv; w]; iv = iv(o);
nI = nI + r;

% the points of every chain from start to end, kb the number of the inner vertex on each of them:
% proportional to the arc length, at least one vertex further than the point before
pc = [(1:C).'; cb; (1:C).'];
po = [zeros(C,1); (1:numel(cb)).' - repelem(cumsum(nB) - nB,nB,1); nB + 1];
pX = [X(sS,:); X(ib,:); X(sE,:)];
[~,o] = sortrows([pc po]);
pc = pc(o); po = po(o); pX = pX(o,:);
al = cumsum([0; vecnorm(diff(pX) * G.M,2,2)]);
al = al - repelem(al(po == 0),nB + 2,1);
kb = round(al ./ repelem(al(po > nB(pc)),nB + 2,1) .* (nI(pc) + 1));
kb(isnan(kb)) = 0;
kb = cummax(max(kb - po,0) + 1e7 * pc) - 1e7 * pc;
kb = po + min(kb,nI(pc) - nB(pc));
kb(po == 0) = 0; kb(po > nB(pc)) = nI + 1;

% the inner vertices evenly on the straight pieces
a = find(po <= nB(pc));
n = kb(a+1) - kb(a);
q = repelem(a,n,1);
t = (1:sum(n)).' - repelem(cumsum(n) - n,n,1);
s = kb(q) + t <= nI(pc(q));
q = q(s); t = t(s);
off = cumsum(nI) - nI;
V(iv(off(pc(q)) + kb(q) + t),:) = G.toP(pX(q,:) + t ./ (kb(q+1) - kb(q)) .* (pX(q+1,:) - pX(q,:)));
V(J,:) = G.toP(Xj);

end

function [X,nb,dirty,nP] = tighten(X,nb,dirty,nP,G)
% every dirty point is dropped or replaced by the cell corners between its neighbours, until none is left

rank = @(i) mod(i * 0.6180339887498949,1);
while true

  % the dirty points before their dirty neighbours in a fixed shuffle, so no two are neighbours
  v = find(dirty);
  if isempty(v), break; end
  p = nb(v,1); n = nb(v,2);
  s = (~dirty(p) | rank(v) > rank(p)) & (~dirty(n) | rank(v) > rank(n));
  v = v(s); p = p(s); n = n(s);
  [hk,hq] = hullChains(X(p,:),X(v,:),X(n,:),G);
  cnt = accumarray(hk,1,[numel(v) 1]);
  h1 = find(diff([0; hk]) > 0);
  dirty(v) = false;

  % a point on its only corner stays
  same = false(numel(v),1);
  same(hk(h1)) = cnt(hk(h1)) == 1 & vecnorm(hq(h1,:) - X(v(hk(h1)),:),2,2) < 1e-9;

  % without a corner between its neighbours it goes
  del = cnt == 0;
  nb(p(del),2) = n(del); nb(n(del),1) = p(del);
  nb(v(del),:) = 0;

  % else it moves to the first corner, new points take the others
  mv = cnt > 0 & ~same;
  X(v(mv),:) = hq(h1(mv(hk(h1))),:);
  ex = find(mv(hk) & diff([0; hk]) == 0);
  c = nP + (1:numel(ex)).';
  nP = nP + numel(ex);
  [X,nb,dirty] = room(X,nb,dirty,nP);
  X(c,:) = hq(ex,:);
  isF = diff([0; hk(ex)]) > 0;
  isL = diff([hk(ex); inf]) > 0;
  nb(c,:) = [c - 1, c + 1];
  nb(c(isF),1) = v(hk(ex(isF))); nb(v(hk(ex(isF))),2) = c(isF);
  nb(c(isL),2) = n(hk(ex(isL))); nb(n(hk(ex(isL))),1) = c(isL);

  % the neighbours of a point that went or moved are looked at again
  t = [p(del | mv); n(del | mv)];
  dirty(t(all(nb(t,:),2))) = true;
end

end

function [X,nb,dirty] = room(X,nb,dirty,n)
% space for n points
if n > size(X,1), X(2*n,:) = 0; nb(2*n,:) = 0; dirty(2*n) = false; end
end

function [hk,hq] = hullChains(P,Q,N,G)
% the cell corners hq the shortest path from P to N bends around in place of P - Q - N, in order, hk
% the triangle: the hull of the cells that are no fill inside the triangle, on the side of Q

hk = zeros(0,1); hq = zeros(0,2);
B = N - P;
sg = sign(B(:,1) .* (Q(:,2) - P(:,2)) - B(:,2) .* (Q(:,1) - P(:,1)));
T = cat(3,P,Q,N);
[s,c] = obstCells(min(T,[],3),max(T,[],3),sg ~= 0,G);

% the cells that overlap the triangle by more than a touch, by the separating axes of the two
isIn = true(numel(s),1);
nr = cell(3,1);
for a = 1:3
  D = T(:,:,mod(a,3)+1) - T(:,:,a);
  nr{a} = -sg .* [D(:,2) -D(:,1)] ./ max(vecnorm(D,2,2),realmin);
  isIn = isIn & sum((c - T(s,:,a)) .* nr{a}(s,:),2) < (1 - 2e-7) * max(nr{a}(s,:) * G.C.',[],2);
end
for a = 1:size(G.axis,1)
  pj = reshape(pagemtimes(T,G.axis(a,:).'),[],3);
  h = (1 - 2e-7) * G.width(a);
  isIn = isIn & c * G.axis(a,:).' + h > min(pj(s,:),[],2) & c * G.axis(a,:).' - h < max(pj(s,:),[],2);
end
s = s(isIn); c = c(isIn,:);

% their corners in the triangle, or just outside where the lattice is distorted
pt = reshape(permute(c,[1 3 2]) + permute(G.C,[3 1 2]),[],2);
pk = repmat(s,size(G.C,1),1);
isIn = true(numel(pk),1);
for a = 1:3
  isIn = isIn & sum((pt - T(pk,:,a)) .* nr{a}(pk,:),2) < 0.05;
end
pt = pt(isIn,:); pk = pk(isIn);

% quickhull for all triangles at once: an edge with a corner above it is split at the farthest one,
% key and width order the edges of a triangle from P to N
[uk,~,pe] = unique(pk);
EA = P(uk,:); EB = N(uk,:); EK = uk;
key = zeros(numel(uk),1); width = ones(numel(uk),1);
hkey = zeros(0,1);
while true
  h = above(pt,EA(pe,:),EB(pe,:),sg(EK(pe)));
  pt = pt(h > 0,:); pe = pe(h > 0); h = h(h > 0);
  if isempty(pe), break; end
  [~,o] = sortrows([pe -h]);
  f = o(diff([0; pe(o)]) > 0);
  ee = pe(f); cp = pt(f,:);
  right = zeros(size(EA,1),1); right(ee) = size(EA,1) + (1:numel(ee));
  width(ee) = width(ee) / 2;
  hk = [hk; EK(ee)]; hkey = [hkey; key(ee) + width(ee)]; hq = [hq; cp]; %#ok<AGROW>
  EA = [EA; cp]; EB = [EB; EB(ee,:)]; EK = [EK; EK(ee)]; %#ok<AGROW>
  key = [key; key(ee) + width(ee)]; width = [width; width(ee)]; %#ok<AGROW>
  EB(ee,:) = cp;
  s = above(pt,EA(right(pe),:),EB(right(pe),:),sg(EK(pe))) > 0;
  pe(s) = right(pe(s));
end
[~,o] = sortrows([hk hkey]);
hk = hk(o); hq = hq(o,:);

end

function h = above(pt,A,B,sg)
% how far the points pt lie above the edges A - B, on the side sg, less a tolerance
D = B - A;
h = sg .* (D(:,1) .* (pt(:,2) - A(:,2)) - D(:,2) .* (pt(:,1) - A(:,1))) - 1e-9 * vecnorm(D,2,2);
end

function lam = clipStep(x,d,G)
% the fraction of every step d from x that stays in the fill

[s,c] = obstCells(min(x,x+d),max(x,x+d),any(d,2),G);

% a cell side next to a filled cell is drawn in, a side next to another such cell pushed out
tin = -inf(numel(s),1); tout = inf(numel(s),1);
for k = 1:size(G.C,1)
  num = G.dist(k) + 1e-9 * (2*isObst(c + G.next(k,:),G) - 1) - (x(s,:) - c) * G.normal(k,:).';
  den = d(s,:) * G.normal(k,:).';
  tin(abs(den) < 1e-14 & num <= 0) = inf;
  t = num ./ den;
  tin(den < -1e-14) = max(tin(den < -1e-14),t(den < -1e-14));
  tout(den > 1e-14) = min(tout(den > 1e-14),t(den > 1e-14));
end
isHit = tout > max(tin,0) & tin < 1;
lam = accumarray(s(isHit,1),max(tin(isHit,1),0),[size(x,1) 1],@min,1);

end

function [s,c] = obstCells(lo,hi,isOn,G)
% the cells c that are no fill around the boxes lo..hi with isOn, s the box

t = find(isOn & anyObst(lo,hi,G));
lo = ceil(lo - G.ext); hi = floor(hi + G.ext);
w = hi(t,1) - lo(t,1) + 1;
n = w .* (hi(t,2) - lo(t,2) + 1);
s = repelem(t,n,1);
r = (1:sum(n)).' - repelem(cumsum(n) - n,n,1) - 1;
w = repelem(w,n,1);
c = [lo(s,1) + mod(r,w), lo(s,2) + floor(r ./ w)];
isO = isObst(c,G);
s = reshape(s(isO),[],1); c = reshape(c(isO,:),[],2);

end

function isO = isObst(c,G)
% whether the cells c are no fill, as every cell off the raster
isO = true(size(c,1),1);
in = all(c >= 1 & c <= G.sz,2);
isO(in) = ~G.fill(c(in,1) + (c(in,2)-1)*G.sz(1));
end

function has = anyObst(lo,hi,G)
% whether the boxes of cells around lo..hi hold a cell that is no fill, from the summed area table
lo = ceil(lo - G.ext); hi = floor(hi + G.ext);
has = any(lo < 1 | hi > G.sz,2);
lo = min(max(lo,1),G.sz); hi = min(max(hi,1),G.sz);
q = @(i,j) G.sum(i + 1 + j*(G.sz(1)+1));
has = has | q(hi(:,1),hi(:,2)) - q(lo(:,1)-1,hi(:,2)) - q(hi(:,1),lo(:,2)-1) + q(lo(:,1)-1,lo(:,2)-1) > 0;
end

function out = missedBoundaries(out,grainId)
% the fill without the regions mostly in gaps one cell wide between two grains

fill = out.fill; sz = size(fill);
k = find(~out.isNotIdx & isfinite(out.site2id(1:numel(out.isNotIdx))));
G = zeros(sz); G(out.site2cell(k)) = grainId(k);

% the neighbours across an edge and, on a square grid, across a corner
O = [1 0; 0 1; 1 1; 1 -1];
m = round(sz / 2);
d = vecnorm(out.cell2pos(m + O) - out.cell2pos(m),2,2);
n = O(:,1) + O(:,2) * sz(1);
c = find(fill);
thin = false(size(c));
for a = find(d < 1.5 * min(d)).'
  g1 = G(c - n(a)); g2 = G(c + n(a));
  thin = thin | (g1 > 0 & g2 > 0 & g1 ~= g2);
end

% the regions: filled cells joined across an edge
id = zeros(sz); id(c) = 1:numel(c);
e = zeros(0,2);
for a = find(d < 1.1 * min(d)).'
  t = id(c + n(a));
  e = [e; find(t > 0) t(t > 0)]; %#ok<AGROW>
end
r = conncomp(graph(e(:,1),e(:,2),[],numel(c))).';
share = accumarray(r,thin) ./ accumarray(r,1);
fill(c(share(r) >= 0.5)) = false;
out.fill = fill;
out.inFill = [];
if any(fill(:)), out.inFill = out.fillTest(fill); end

end

function G = fillGeometry(out)
% the lattice of the filled cells: in lattice coordinates cell (i,j) of the raster out.fill is the
% Voronoi cell of the point (i,j)

G.fill = out.fill;
G.sz = size(out.fill);
G.sum = zeros(G.sz + 1);
G.sum(2:end,2:end) = cumsum(cumsum(~out.fill,1),2);

% to positions and back, the lattice basis M from the middle of the raster
G.toP = out.cell2pos;
c = round(G.sz / 2);
G.M = G.toP(c + eye(2)) - G.toP(c);
G.toU = @(p) toCell(p,G.toP(c) - c * G.M,G.M,G.toP);

% the corners of a cell, counterclockwise around its centre
[i,j] = ndgrid(-2:2);
nbr = [i(:) j(:)]; nbr = nbr(any(nbr,2),:);
[vx,cx] = voronoin([0 0; nbr * G.M]);
C = vx(cx{1},:) / G.M;
[~,o] = sort(atan2(C(:,2),C(:,1)));
G.C = C(o,:);
G.ext = max(abs(C(:)));

% its sides: outward normal, distance from the centre, the cell beyond; half of them as axes
D = circshift(G.C,-1) - G.C;
G.normal = [D(:,2) -D(:,1)] ./ vecnorm(D,2,2);
G.dist = sum(G.C .* G.normal,2);
G.next = round(G.C + circshift(G.C,-1));
h = 1:size(C,1)/2;
G.axis = G.normal(h,:); G.width = G.dist(h);
G.side = D(h,:);

end

function u = toCell(p,p0,M,toP)
% lattice coordinates of the positions p, exact after one step on a rigid lattice
u = (p - p0) / M;
for it = 1:4, u = u + (p - toP(u)) / M; end
end

function [k,a,b] = fillEntry(V,F,k,dE,inFill,tol,dxy)
% of the segments k with an end inside the fill those that leave it in
% between: that end, the first if both are, and the sample outside nearest to it

in1 = dE(:,1) > tol;
a = V(F(k,2),:); a(in1,:) = V(F(k(in1),1),:);
b = V(F(k,1),:); b(in1,:) = V(F(k(in1),2),:);
T = max(2,ceil(3 * vecnorm(b - a,2,2) / dxy));
s = repelem((1:numel(k)).',T-1,1);
t = ((1:numel(s)).' - repelem(cumsum(T-1) - (T-1),T-1,1)) ./ T(s);
isO = inFill(a(s,:) + t .* (b(s,:) - a(s,:))) < -tol;
t = accumarray(s(isO,1),t(isO,1),[numel(k) 1],@min,inf);
o = isfinite(t);
k = k(o); a = a(o,:); b = a + t(o,1) .* (b(o,:) - a);

end
