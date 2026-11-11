function [V,F,I_FD,V0] = sif_ref(V,varargin)
% reference: the shortest network of the given topology and homotopy class in the filled cells
%
% every chain is pulled taut by triangle shortcuts around the corners of the cells in its way, every
% junction goes to the Fermat point of the first bends of its chains, sliding along the walls

global SIFREF
if ischar(V), fh = str2func(V); V = fh(varargin{:}); return; end
[F,I_FD,grainId,out] = deal(varargin{:});
[V,F,I_FD,isB] = sifCut(V,F,I_FD,grainId,out);
V0 = V;
G = sifGeom(out);
segId = find(isB);
e = F(segId,:);
nV = size(V,1);
vB = unique(e);
isFree = false(nV,1); isFree(vB) = out.inFill(V(vB,:)) > out.epsilon;
keep = any(isFree(e),2);
e = e(keep,:); segId = segId(keep);
m = size(e,1);
deg = accumarray(e(:),1,[nV 1]);
isNode = (~isFree | deg ~= 2) & deg > 0;
U = G.toU(V);

% the fixed vertices exactly onto the cell edges the bisection found them next to
r = round(U - 0.5) + 0.5;
sn = abs(U - r) < 1e-4 & ~isFree;
U(sn) = r(sn);
inc = accumarray(e(:),[1:m 1:m].',[nV 1],@(x){x});

% chains between nodes, then the cycles without a node
used = false(m,1);
cv = {}; cs = {}; isCyc = false(0,1);
for pass = 1:2
  if pass == 1, starts = find(isNode).'; else, starts = e(~used,1).'; end
  for a = starts
    for s = inc{a}.'
      if used(s), continue; end
      vs = a; ss = zeros(1,0); cur = a; sg = s;
      while true
        used(sg) = true; ss(end+1) = sg; %#ok<AGROW>
        cur = e(sg,1) + e(sg,2) - cur;
        vs(end+1) = cur; %#ok<AGROW>
        if isNode(cur) || cur == a, break; end
        t = inc{cur}; sg = t(t ~= sg);
      end
      cv{end+1} = vs; cs{end+1} = ss; isCyc(end+1) = pass == 2; %#ok<AGROW>
    end
  end
end
nC = numel(cv);
P = cell(nC,1);
for k = 1:nC, P{k} = U(cv{k},:); end

% the chain ends at every free node
freeNode = find(isNode & isFree).';
ends = cell(nV,1);
for k = find(~isCyc(:)).'
  ends{cv{k}(1)}(end+1,:) = [k 1];
  ends{cv{k}(end)}(end+1,:) = [k 2];
end

L0 = netLength(P);
for k = 1:nC
  P{k} = tighten(P{k},G);
  if isCyc(k) && size(P{k},1) > 3
    P{k} = tighten([P{k}(2:end,:); P{k}(2,:)],G);
    U(cv{k}(1),:) = P{k}(1,:);
  end
end
L1 = netLength(P);

nSweep = 0; mv = inf;
while mv > 1e-4 && nSweep < 150
  nSweep = nSweep + 1; mv = 0;
  for j = freeNode
    E = ends{j};
    q = zeros(size(E,1),2);
    for i = 1:size(E,1)
      Pk = P{E(i,1)};
      if E(i,2) == 1, q(i,:) = Pk(2,:); else, q(i,:) = Pk(end-1,:); end
    end
    x = U(j,:);
    y = clipSlide(x,fermat(q,x),q,G);
    d = norm(y - x);
    if d < 1e-6, continue; end
    mv = max(mv,d);
    for i = 1:size(E,1)
      Pk = P{E(i,1)};
      if E(i,2) == 1, Pk = [y; Pk]; else, Pk = [Pk; y]; end %#ok<AGROW>
      P{E(i,1)} = tighten(Pk,G);
    end
    U(j,:) = y;
  end
end
L2 = netLength(P);
SIFREF = struct('L0',L0,'Ltaut',L1,'L',L2,'sweeps',nSweep,'chains',nC,'cycles',nnz(isCyc), ...
  'bends',sum(cellfun(@(p) size(p,1),P)) - 2*nC,'nodes',numel(freeNode),'dxy',out.dxy);

% the vertices of every chain along its polyline, one on every bend
dup = zeros(0,1);
for k = 1:nC
  vs = cv{k}; Pk = P{k};
  b = size(Pk,1) - 2;
  sg = segId(cs{k}(end));
  isLast = F(sg,2) == vs(end);
  for i = 1:b - (numel(vs) - 2)
    w = size(V,1) + 1;
    V0(w,:) = (V0(F(sg,1),:) + V0(F(sg,2),:)) / 2;
    V(w,:) = V0(w,:);
    F(end+1,:) = [w F(sg,2)]; %#ok<AGROW>
    F(sg,2) = w;
    dup(end+1,1) = sg; %#ok<AGROW>
    if isLast, vs = [vs(1:end-i) w vs(end-i+1:end)]; else, vs = [vs(1:end-1) w vs(end)]; end
  end
  mi = numel(vs) - 2;
  if mi == 0, continue; end
  s = [0; cumsum(vecnorm(diff(Pk),2,2))];
  if s(end) < 1e-12
    pts = repmat(Pk(1,:),mi,1);
  else
    kb = round(s(2:end-1) / s(end) * (mi+1));
    for i = 1:b, kb(i) = min(max([kb(i), i, kb(max(i-1,1)) + (i > 1)]),mi - (b - i)); end
    si = interp1([0; kb; mi+1],s,(1:mi).');
    pts = interp1(s,Pk,si);
  end
  V(vs(2:end-1),:) = G.toP(pts);
end
V(freeNode,:) = G.toP(U(freeNode,:));
cyc = find(isCyc(:)).';
for k = cyc, V(cv{k}(1),:) = G.toP(P{k}(1,:)); end
I_FD = [I_FD; I_FD(dup,:)];

end

function L = netLength(P)
L = 0;
for k = 1:numel(P), L = L + sum(vecnorm(diff(P{k}),2,2)); end
end

function P = tighten(P,G)
% triangle shortcuts until every inner point of the polyline wraps a corner
i = 2; it = 0;
while i < size(P,1)
  it = it + 1;
  if it > 500 + 20*size(P,1), error('tighten does not end at point %d of %d',i,size(P,1)); end
  if norm(P(i,:) - P(i-1,:)) < 1e-8 || (i == size(P,1) - 1 && norm(P(i,:) - P(i+1,:)) < 1e-8)
    P(i,:) = []; i = max(2,i-1); continue
  end
  Q = shortcut(P(i-1,:),P(i,:),P(i+1,:),G);
  if size(Q,1) == 1 && norm(Q - P(i,:)) < 1e-9
    i = i + 1;
  else
    P = [P(1:i-1,:); Q; P(i+1:end,:)];
    i = max(2,i-1);
  end
end
end

function Q = shortcut(p,v,n,G)
% the taut path from p to n in place of p - v - n, without its ends
Q = zeros(0,2);
b = n - p; L = norm(b);
cr = b(1)*(v(2)-p(2)) - b(2)*(v(1)-p(1));
if abs(cr) < 1e-12 || L < 1e-12, return; end
sg = sign(cr);
T = [p; v; n];
lo = round(min(T,[],1)); hi = round(max(T,[],1));
[I,J] = ndgrid(lo(1):hi(1),lo(2):hi(2));
I = I(:); J = J(:);
ob = true(numel(I),1);
in = I >= 1 & I <= G.sz(1) & J >= 1 & J <= G.sz(2);
ob(in) = G.obst(I(in) + (J(in)-1)*G.sz(1));
c = [I(ob) J(ob)];
if isempty(c), return; end

% the cells that overlap the triangle by more than a touch
h = 0.5 - 1e-7;
blk = c(:,1) + h > min(T(:,1)) & c(:,1) - h < max(T(:,1)) & c(:,2) + h > min(T(:,2)) & c(:,2) - h < max(T(:,2));
for k = 1:3
  a = T(k,:); d = T(mod(k,3)+1,:) - a;
  nrm = -sg * [d(2) -d(1)];                   % outward normal
  blk = blk & (c - a) * nrm.' - h * sum(abs(nrm)) < 0;
end
c = c(blk,:);
if isempty(c), return; end

% their corners in the triangle, above the base
pts = [c + [0.5 0.5]; c + [0.5 -0.5]; c + [-0.5 0.5]; c + [-0.5 -0.5]];
pts = unique(pts,'rows');
inT = true(size(pts,1),1);
for k = 1:3
  a = T(k,:); d = T(mod(k,3)+1,:) - a;
  nrm = -sg * [d(2) -d(1)] / norm(d);
  inT = inT & (pts - a) * nrm.' < 1e-7;
end
pts = pts(inT,:);
hgt = sg * (b(1)*(pts(:,2)-p(2)) - b(2)*(pts(:,1)-p(1))) / L;
pts = pts(hgt > 1e-9,:);
if isempty(pts), return; end

% the hull chain from p over the corners to n
X = [p; n; pts];
K = convhull(X(:,1),X(:,2),'Simplify',true);
K = K(1:end-1);
K = circshift(K,1 - find(K == 2));            % starts at n
iP = find(K == 1);
if sg > 0
  Q = X(K(iP-1:-1:2),:);
else
  Q = X(K(iP+1:end),:);
end

% without the corners the path passes straight
R = [p; Q; n]; k = 2;
while k < size(R,1)
  d = R(k+1,:) - R(k-1,:); w = R(k,:) - R(k-1,:);
  if abs(d(1)*w(2) - d(2)*w(1)) < 1e-9 * norm(d), R(k,:) = []; k = max(2,k-1); else, k = k + 1; end
end
Q = R(2:end-1,:);
end

function y = fermat(q,x)
% the point of least total distance to the points q, from x
for k = 1:size(q,1)
  d = q - q(k,:); r = vecnorm(d,2,2);
  far = r > 1e-9;
  if norm(sum(d(far,:) ./ r(far),1)) <= nnz(~far) + 1e-12, y = q(k,:); return; end
end
y = x;
if any(vecnorm(q - y,2,2) < 1e-9), y = mean(q,1); end
for it = 1:500
  r = max(vecnorm(q - y,2,2),1e-12);
  yn = sum(q ./ r,1) / sum(1 ./ r);
  if norm(yn - y) < 1e-10, y = yn; return; end
  y = yn;
end
end

function y = clipSlide(x,y,q,G)
% from x towards y as far as the fill reaches, along a wall where it blocks as far as the distances to q fall
d = y - x;
lam = clip(x,d,G);
if lam * norm(d) > 1e-7, y = x + lam * d; return; end
y = x; best = 1e-7;
for a = [1 0; 0 1; -1 0; 0 -1].'
  a = a.'; %#ok<FXSET>
  if d * a.' <= 0, continue; end
  slope = @(t) sum(((x + t*a - q) * a.') ./ max(vecnorm(x + t*a - q,2,2),1e-12));
  if slope(1e-9) >= 0, continue; end
  hi = 4 * norm(d);
  hi = hi * clip(x,hi*a,G);
  if hi <= best, continue; end
  if slope(hi) > 0
    lo = 0;
    for it = 1:50
      t = (lo + hi) / 2;
      if slope(t) > 0, hi = t; else, lo = t; end
    end
  end
  if hi > best, best = hi; y = x + hi * a; end
end
end

function lam = clip(x,d,G)
% the fraction of the step d from x that stays in the fill
lam = 1;
if norm(d) < 1e-12, return; end
lo = round(min(x,x+d)); hi = round(max(x,x+d));
[I,J] = ndgrid(lo(1):hi(1),lo(2):hi(2));
I = I(:); J = J(:);
ob = true(numel(I),1);
in = I >= 1 & I <= G.sz(1) & J >= 1 & J <= G.sz(2);
ob(in) = G.obst(I(in) + (J(in)-1)*G.sz(1));
c = [I(ob) J(ob)];
if isempty(c), return; end
tmin = -inf(size(c,1),1); tmax = inf(size(c,1),1);
for a = 1:2
  % a side next to a filled cell is drawn in, a side next to another such cell pushed out
  e1 = zeros(1,2); e1(a) = 1;
  hl = 0.5 + 1e-9 * (1 - 2*~isObst(c - e1,G)); hu = 0.5 + 1e-9 * (1 - 2*~isObst(c + e1,G));
  if abs(d(a)) < 1e-14
    o = x(a) <= c(:,a) - hl | x(a) >= c(:,a) + hu;
    tmin(o) = inf;
  else
    t1 = (c(:,a) - hl - x(a)) / d(a); t2 = (c(:,a) + hu - x(a)) / d(a);
    tmin = max(tmin,min(t1,t2)); tmax = min(tmax,max(t1,t2));
  end
end
hit = tmax > max(tmin,0) & tmin < 1;
lam = min([1; max(tmin(hit),0)]);
end

function ob = isObst(c,G)
ob = true(size(c,1),1);
in = c(:,1) >= 1 & c(:,1) <= G.sz(1) & c(:,2) >= 1 & c(:,2) <= G.sz(2);
ob(in) = G.obst(c(in,1) + (c(in,2)-1)*G.sz(1));
end
