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

% positive inside the filled cells, negative outside
nearF = nearestId(out.fillXY);
nearO = nearestId(out.otherXY);
inFill = @(p) vecnorm(p - out.otherXY(nearO(p),:),2,2) - vecnorm(p - out.fillXY(nearF(p),:),2,2);

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
for it = 1:30
  mid = (lo + hi) / 2;
  isA = (inFill(a + mid .* (b - a)) > 0) == aIn;
  lo(isA) = mid(isA); hi(~isA) = mid(~isA);
end
nV = size(V,1);
V = [V; a + (lo + hi) / 2 .* (b - a)];
F = [F; nV + (1:numel(cut)).', F(cut,2)];
F(cut,2) = nV + (1:numel(cut)).';
I_FD = [I_FD; I_FD(cut,:)];
isB = [isB; true(numel(cut),1)];

e = F(isB,:);
A = sparse(e,fliplr(e),1,size(V,1),size(V,1));

isFixed = true(size(V,1),1);
vB = unique(e);
isFixed(vB) = inFill(V(vB,:)) <= tol;

V0 = V;
Vlast = V;
while true
  V = V0;
  m = ~isFixed & any(A,2);
  V(m,:) = (spdiags(sum(A(m,:),2) + 1e-3,0,nnz(m),nnz(m)) - A(m,m)) \ ...
    (A(m,~m) * V0(~m,:) + 1e-3 * V0(m,:));

  % samples, half a pixel apart, of the area every segment sweeps that moved since the last round
  chg = any(V ~= Vlast,2);
  isM = any(reshape(chg(e),size(e)),2);
  em = e(isM,:);
  dV = vecnorm(V - V0,2,2);
  K = max(1,ceil(2 * max(reshape(dV(em),size(em)),[],2) / out.dxy));
  seg = repelem((1:size(em,1)).',K+1,1);
  l = ((1:numel(seg)).' - repelem(cumsum(K+1) - K,K+1,1)) ./ K(seg);
  t = (0:8)/8;
  sweep = @(k) (1-l) .* ((1-t) .* V0(em(seg,1),k) + t .* V0(em(seg,2),k)) + ...
    l .* ((1-t) .* V(em(seg,1),k) + t .* V(em(seg,2),k));
  Px = sweep(1); Py = sweep(2);
  isOut = any(reshape(inFill([Px(:),Py(:)]) < -tol,size(Px)),2);
  bad = crossing(V,e,isM);
  bad(isM) = bad(isM) | accumarray(seg,double(isOut),[size(em,1) 1],@max) > 0;
  if ~any(bad), break; end
  isFixed(e(bad,:)) = true;
  Vlast = V;
end

end

function isX = crossing(V,e,isM)
% the segments of e with isM that cross another one of e

isX = isM;
if ~any(isM), return; end

% candidates from the 3 x 3 buckets, as large as the longest segment, around the midpoint
a = V(e(:,1),:);
d = V(e(:,2),:) - a;
c = floor((a + d/2) / max(vecnorm(d,2,2)));
c = c - min(c,[],1) + 2;
nx = max(c(:,1)) + 2;
key = c(:,1) + c(:,2)*nx;
[ks,ord] = sort(key);
[u,first] = unique(ks);
n = diff([first; numel(ks)+1]);
q = find(isM);
[o1,o2] = meshgrid(-1:1);
i = cell(9,1); j = cell(9,1);
for k = 1:9
  [tf,loc] = ismember(key(q) + o1(k) + o2(k)*nx, u);
  cnt = n(loc(tf));
  i{k} = repelem(q(tf), cnt, 1);
  j{k} = ord(repelem(first(loc(tf)) - 1 - cumsum(cnt) + cnt, cnt, 1) + (1:sum(cnt)).');
end
i = vertcat(i{:});
j = vertcat(j{:});

% proper crossings of segments without a common vertex
w = a(j,:) - a(i,:);
den = d(i,1).*d(j,2) - d(i,2).*d(j,1);
s = (w(:,1).*d(j,2) - w(:,2).*d(j,1)) ./ den;
t = (w(:,1).*d(i,2) - w(:,2).*d(i,1)) ./ den;
x = s > 0 & s < 1 & t > 0 & t < 1 & ~any(e(i,:) == e(j,1) | e(i,:) == e(j,2),2);
isX = false(size(e,1),1);
isX(i(x)) = true;

end
