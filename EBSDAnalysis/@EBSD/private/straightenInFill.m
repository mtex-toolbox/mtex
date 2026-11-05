function [V,F,I_FD] = straightenInFill(V,F,I_FD,grainId,out)
% grain boundaries straight through the cells the alpha closing filled
%
% Syntax
%   [V,F,I_FD] = straightenInFill(V,F,I_FD,grainId,out)
%
% Description
% Through filled cells a grain boundary follows the bisectors between the
% measured pixels around them, which bends it around the middle of a crack
% or a cluster of notIndexed pixels. A boundary vertex inside the filled
% cells moves onto the straight line between the vertices around it, as for
% an isotropic boundary energy, while a vertex on the edge of a measured, an
% unfilled or an exterior cell stays. A segment that would sweep over
% anything but filled cells or cross another boundary keeps its vertices
% where they are, so every measured pixel stays in its grain and the outer
% boundary never leaves the closing.
%
% Input
%  V,F,I_FD - vertices, segments and segment × pixel incidence
%  grainId  - grain of every pixel
%  out      - output of spatialDecompositionGrid
%
% Output
%  V,F,I_FD - with the boundary segments split where they enter the filled cells

inFill = out.inFill;

% segments between two grains or at the outer boundary
[f,d] = find(I_FD);
nF = size(F,1);
isB = accumarray(f,grainId(d),[nF 1],@min) ~= accumarray(f,grainId(d),[nF 1],@max) | ...
  accumarray(f,1,[nF 1]) == 1;

% a boundary segment entering the filled cells gets a vertex there
tol = out.epsilon;
dE = reshape(inFill(V(F(isB,:),:)),[],2);
cut = find(isB);
cut = cut(max(dE,[],2) > tol & min(dE,[],2) < -tol);
a = V(F(cut,1),:); b = V(F(cut,2),:);
lo = zeros(numel(cut),1); hi = ones(numel(cut),1);
aIn = inFill(a) > 0;
for it = 1:16
  mid = (lo + hi) / 2;
  isA = (inFill(a + mid .* (b - a)) > 0) == aIn;
  lo(isA) = mid(isA); hi(~isA) = mid(~isA);
end
nV = size(V,1);
V = [V; a + (lo + hi) / 2 .* (b - a)];
F = [F; nV + (1:numel(cut)).', F(cut,2)];
F(cut,2) = nV + (1:numel(cut)).';
r = zeros(nF,1); r(cut) = nF + (1:numel(cut)); s = r(f) > 0;
I_FD = sparse([f; r(f(s))], [d; d(s)], 1, nF + numel(cut), size(I_FD,2));
isB = [isB; true(numel(cut),1)];

e = F(isB,:);
A = sparse(e,fliplr(e),1,size(V,1),size(V,1));

isFixed = true(size(V,1),1);
vB = unique(e);
isFixed(vB) = inFill(V(vB,:)) <= tol;

% the free vertices relax component by component, a component again only after it lost a vertex
V0 = V;
m = ~isFixed & any(A,2);
s = m;
while true
  Vlast = V;
  V(s,:) = (spdiags(sum(A(s,:),2) + 1e-3,0,nnz(s),nnz(s)) - A(s,s)) \ ...
    (A(s,~s) * V(~s,:) + 1e-3 * V0(s,:));

  % samples, a third of a pixel apart, of the area every segment sweeps that moved since the last round
  chg = any(V ~= Vlast,2);
  isM = any(reshape(chg(e),size(e)),2);
  em = e(isM,:);
  dV = vecnorm(V - V0,2,2);
  T = max(1,ceil(3 * max(vecnorm(V0(em(:,2),:) - V0(em(:,1),:),2,2), ...
    vecnorm(V(em(:,2),:) - V(em(:,1),:),2,2)) / out.dxy));
  K = max(1,ceil(3 * max(reshape(dV(em),size(em)),[],2) / out.dxy));
  n = (T+1) .* (K+1);
  seg = repelem((1:size(em,1)).',n,1);
  r = (1:numel(seg)).' - repelem(cumsum(n) - n,n,1) - 1;
  t = mod(r,T(seg)+1) ./ T(seg);
  l = floor(r ./ (T(seg)+1)) ./ K(seg);
  P = (1-l) .* ((1-t) .* V0(em(seg,1),:) + t .* V0(em(seg,2),:)) + ...
    l .* ((1-t) .* V(em(seg,1),:) + t .* V(em(seg,2),:));
  isOut = inFill(P) < -tol;
  bad = crossing(V,e,isM);
  bad(isM) = bad(isM) | accumarray(seg,double(isOut),[size(em,1) 1],@max) > 0;
  if ~any(bad), break; end

  lab = zeros(size(V,1),1);
  lab(m) = conncomp(graph(A(m,m)));
  x = e(bad,:);
  isFixed(x) = true;
  V(x,:) = V0(x,:);
  m = ~isFixed & any(A,2);
  s = m & ismember(lab,lab(x));
end

end

function isX = crossing(V,e,isM)
% the segments of e with isM that cross another one of e

isX = isM;
if ~any(isM), return; end

% candidates: the segments in a common bucket, twice the median segment long, of their boxes
a = V(e(:,1),:);
d = V(e(:,2),:) - a;
h = 2*median(vecnorm(d,2,2));
lo = floor(min(a,a+d) / h);
hi = floor(max(a,a+d) / h) - lo + 1;
lo = lo - min(lo,[],1);
n = prod(hi,2);
s = repelem((1:size(e,1)).',n,1);
r = (1:numel(s)).' - repelem(cumsum(n) - n,n,1) - 1;
key = lo(s,1) + mod(r,hi(s,1)) + (lo(s,2) + floor(r ./ hi(s,1))) * (max(lo(:,1) + hi(:,1)) + 1);
[key,o] = sort(key);
s = s(o);
first = find([true; diff(key) > 0]);
g = cumsum([true; diff(key) > 0]);
n = diff([first; numel(s) + 1]);
q = find(isM(s));
m = n(g(q));
i = repelem(s(q),m,1);
j = s(repelem(first(g(q)) - 1,m,1) + (1:sum(m)).' - repelem(cumsum(m) - m,m,1));

% each pair once, proper crossings of segments without a common vertex
u = ~isM(j) | j > i;
i = i(u); j = j(u);
w = a(j,:) - a(i,:);
den = d(i,1).*d(j,2) - d(i,2).*d(j,1);
s = (w(:,1).*d(j,2) - w(:,2).*d(j,1)) ./ den;
t = (w(:,1).*d(i,2) - w(:,2).*d(i,1)) ./ den;
x = s > 0 & s < 1 & t > 0 & t < 1 & ~any(e(i,:) == e(j,1) | e(i,:) == e(j,2),2);
isX = false(size(e,1),1);
isX([i(x); j(x)]) = true;
isX = isX & isM;

end
