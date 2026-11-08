function grainId = absorbInteriorPixels(grains,ebsd,grainId,lat)
% assign a grainId to pixels at 0 that lie entirely within one grain
%
% A pixel at 0 whose unit cell, pulled slightly towards its centre, no
% boundary segment meets takes the grain of a neighbour, sharing an edge or
% a corner, whose centre no segment separates from its own, and passes it
% on the same way. Every segment is tested only against the pixels of the
% lattice cells it passes, so nothing is searched.
%
% Input
%  grains  - @grain2d
%  ebsd    - @EBSD
%  grainId - nEbsd × 1 grain id per pixel (0 = unassigned)
%  lat     - ebsd.lattice
%
% Output
%  grainId - updated grain id per pixel

z = find(grainId == 0);
if isempty(z), return; end

% raster of the lattice slots, 0 where the map has no pixel
ij = lat.ij - min(lat.ij,[],1) + 2; sz = max(ij,[],1) + 1;
slot = ij(:,1) + (ij(:,2) - 1) * sz(1);
P = zeros(sz); P(slot) = 1:numel(slot);
xy = [ebsd.pos.x(:) ebsd.pos.y(:)];

% the neighbours sharing an edge before those sharing a corner, 0 for an empty slot
[di,dj] = ndgrid(-1:1); o = [di(:) dj(:)];
[d,k] = sort(vecnorm(o * lat.A.',2,2)); o = o(k(d > 0 & d < 1.5 * lat.dxy),:);
nb = P(slot(z) + o(:,1).' + o(:,2).' * sz(1));

% every boundary segment in the cells whose unit cell its box meets, of the zero pixels and their neighbours
isI = false(sz); isI(slot(z)) = true; isI(slot(nb(nb > 0))) = true;
gB = grains.boundary;
a = [gB.allV.x(gB.F(:,1)) gB.allV.y(gB.F(:,1))];
b = [gB.allV.x(gB.F(:,2)) gB.allV.y(gB.F(:,2))];
u1 = (a - lat.origin) / lat.A.' - min(lat.ij,[],1) + 2;
u2 = (b - lat.origin) / lat.A.' - min(lat.ij,[],1) + 2;
mg = max(abs([ebsd.unitCell.x(:) ebsd.unitCell.y(:)] / lat.A.'),[],1) - 0.5 + 1e-6;
lo = max(round(min(u1,u2) - mg),1); hi = min(round(max(u1,u2) + mg),sz);
w = hi(:,1) - lo(:,1) + 1; n = w .* (hi(:,2) - lo(:,2) + 1);
s = repelem((1:size(a,1)).',n);
r = (1:numel(s)).' - repelem(cumsum(n) - n,n) - 1;
c = lo(s,1) + mod(r,w(s)) + (lo(s,2) + floor(r ./ w(s)) - 1) * sz(1);
k = isI(c); [c,o2] = sort(c(k)); s = s(k); s = s(o2);
cnt = accumarray(c,1,[numel(P) 1]); first = cumsum(cnt) - cnt;

% a zero pixel is crossed if a segment meets its nudged unit cell
[i,e] = segsOf(slot(z));
uc = 0.95 * [ebsd.unitCell.x(:) ebsd.unitCell.y(:)];
crossed = false(size(z));
crossed(i(~separated(xy(z(i),:),uc,a(e,:),b(e,:)))) = true;

% the grain passes along every link no segment of its two cells cuts
u = find(~crossed);
tested = false(numel(u),size(o,1));
while true
  nNew = 0;
  for k = 1:size(o,1)
    j = find(grainId(z(u)) == 0 & ~tested(:,k) & nb(u,k) > 0);
    j = j(grainId(nb(u(j),k)) > 0);
    tested(j,k) = true;
    p = z(u(j)); q = nb(u(j),k);
    [i,e] = segsOf([slot(p); slot(q)]);
    i = mod(i - 1,numel(p)) + 1;
    cut = false(size(p));
    cut(i(cuts(xy(p(i),:),xy(q(i),:),a(e,:),b(e,:)))) = true;
    grainId(p(~cut)) = grainId(q(~cut));
    nNew = nNew + nnz(~cut);
  end
  if nNew == 0, break; end
end

  function [i,e] = segsOf(cl)
    % the segments of the cells cl, with the index into cl
    m = cnt(cl);
    i = repelem((1:numel(cl)).',m);
    e = s(repelem(first(cl),m) + (1:sum(m)).' - repelem(cumsum(m) - m,m));
  end

end

function sep = separated(cen,uc,a,b)
% whether the segments a-b and the convex polygons cen + uc have a separating axis

d = b - a;
pr = (cen(:,1) - a(:,1) + uc(:,1).') .* d(:,2) - (cen(:,2) - a(:,2) + uc(:,2).') .* d(:,1);
sep = all(pr > 0,2) | all(pr < 0,2);
e = circshift(uc,-1) - uc;
nrm = [e(:,2) -e(:,1)] * sign(sum(e(:,1).*circshift(e(:,2),-1) - e(:,2).*circshift(e(:,1),-1)));
h = sum(nrm .* uc,2).';
pa = (a(:,1) - cen(:,1)) .* nrm(:,1).' + (a(:,2) - cen(:,2)) .* nrm(:,2).';
pb = (b(:,1) - cen(:,1)) .* nrm(:,1).' + (b(:,2) - cen(:,2)) .* nrm(:,2).';
sep = sep | any(pa > h & pb > h,2);

end

function x = cuts(p1,p2,a,b)
% whether the segments p1-p2 and a-b meet

cr = @(u,v) u(:,1).*v(:,2) - u(:,2).*v(:,1);
o1 = cr(b - a,p1 - a); o2 = cr(b - a,p2 - a);
o3 = cr(p2 - p1,a - p1); o4 = cr(p2 - p1,b - p1);
t = [sum((a - p1).*(p2 - p1),2) sum((b - p1).*(p2 - p1),2)];
x = o1.*o2 <= 0 & o3.*o4 <= 0 & ...
  ~(o1 == 0 & o2 == 0 & (max(t,[],2) < 0 | min(t,[],2) > sum((p2 - p1).^2,2)));

end
