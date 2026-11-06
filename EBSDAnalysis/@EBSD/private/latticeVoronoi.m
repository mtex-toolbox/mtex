function [V,F,I_FD] = latticeVoronoi(XY,slot,szP,A,numReal,epsilon,alpha)
% Voronoi decomposition of sites that sit on the slots of a lattice raster
%
% Syntax
%   [V,F,I_FD] = latticeVoronoi(XY,slot,szP,A,numReal,epsilon,alpha)
%
% Description
% The cell of a site is a box around it clipped against the bisectors of the
% sites on the lattice slots around it, nearest first, until the next one is
% further than twice the radius of the cell. The alpha closing leaves no
% region without sites wider than 2*alpha cells, so the reach is bounded; a
% cell still open at the rim of a wider bay is computed again with a reach 4
% and 16 times as large. The vertex that the cells meeting there computed
% each for themselves is welded within epsilon. Distances are counted in
% steps of A shrunk by the smallest ratio of actual to ideal distance between
% neighbouring sites, so a distorted lattice does not end the search early.
%
% Input
%  XY      - sites, the ones whose cells are wanted in the first numReal rows
%  slot    - linear index of every site in a raster of size szP
%  A       - lattice basis, the columns the physical steps along i and j
%  epsilon - welding tolerance: vertices closer are one, shorter segments go
%  alpha   - closing radius in lattice steps
%
% Output, as jcvoronoi2
%  V       - nV x 2 vertices
%  F       - nF x 2 vertex indices of the segments that bound a cell of the first numReal sites
%  I_FD    - nF x numReal sparse incidence segment x site
%
% latticeVoronoi_mex does the same where it is compiled, this code is its fallback

A = A * neighbourRatio(XY,slot,szP,A);

persistent hasMex
if isempty(hasMex), hasMex = exist('latticeVoronoi_mex','file') == 3; end
if hasMex
  [V,F,I_FD] = latticeVoronoi_mex(double(XY),double(slot),double(szP),double(A),...
    double(numReal),double(epsilon),double(alpha));
  return
end

lookup = zeros(prod(szP),1);
lookup(slot) = 1:size(XY,1);
[r0,c0] = ind2sub(szP,slot(1:numReal));
dxy = mean(vecnorm(A,2,1));
kmax = ceil(2*alpha) + 2;

% the faces of every cell as site, neighbour and end points, each face from its lower site
S = cell(3,1); Q = S; P1 = S; P2 = S;
todo = (1:numReal).';
for lv = 1:3
  k = kmax * 4^(lv-1);
  [X,Y,G,m] = cellsOf(XY,lookup,szP,todo,r0(todo),c0(todo),A,k,1.5*k*dxy);
  [S{lv},Q{lv},P1{lv},P2{lv},isOpen] = facesOf(XY,todo,X,Y,G,m);
  todo = todo(isOpen);
  if isempty(todo), break, end
end
assert(isempty(todo),'latticeVoronoi:open','%d cells reach beyond 16 times the closing',numel(todo));
S = vertcat(S{:}); Q = vertcat(Q{:});

% weld the end points, drop the faces that collapsed, one row per vertex pair
[V,id] = weld([vertcat(P1{:}); vertcat(P2{:})],epsilon);
F = reshape(id,[],2);
keep = F(:,1) ~= F(:,2);
keep(keep) = vecnorm(V(F(keep,1),:) - V(F(keep,2),:),2,2) > epsilon;
F = sort(F(keep,:),2); S = S(keep); Q = Q(keep);
[key,~,row] = unique(F(:,1) * size(V,1) + F(:,2) - 1);
F = [floor(key / size(V,1)) mod(key,size(V,1)) + 1];
isR = Q <= numReal;
I_FD = spones(sparse([row; row(isR)],[S; Q(isR)],1,size(F,1),numReal));

end

% -------------------------------------------------------------------------
function rho = neighbourRatio(XY,slot,szP,A)
% the smallest ratio of actual to ideal distance between sites one lattice step apart, at most 1

lookup = zeros(prod(szP),1); lookup(slot) = 1:numel(slot);
[r,c] = ind2sub(szP,slot(:));
rho = 1;
for o = [1 0; 0 1; 1 1; 1 -1].'
  q = zeros(size(r));
  in = r + o(1) <= szP(1) & c + o(2) >= 1 & c + o(2) <= szP(2);
  q(in) = lookup(slot(in) + o(1) + o(2)*szP(1));
  s = find(q > 0);
  rho = min([rho; vecnorm(XY(q(s),:) - XY(s,:),2,2) / norm(A*o)]);
end

end

% -------------------------------------------------------------------------
function [X,Y,G,m] = cellsOf(XY,lookup,szP,s,r0,c0,A,k,W)
% the cells of the sites s at (r0,c0) as vertices relative to the site, from a
% box of half width W clipped by the sites within k lattice steps. Edge j runs
% from vertex j to j+1 along the bisector with site G(:,j), 0 on the box

[di,dj] = ndgrid(-k:k);
o = [di(:) dj(:)];
o = o(any(o,2),:);
d = vecnorm(o * A.',2,2);
[d,ord] = sort(d);
o = o(ord,:);

n = numel(s);
X = W * repmat([-1 1 1 -1],n,1);
Y = W * repmat([-1 -1 1 1],n,1);
G = zeros(n,4);
m = repmat(4,n,1);
rad2 = repmat(2*W^2,n,1);
act = (1:n).';
for j = 1:size(o,1)

  % a closed cell cannot be cut by a site further than twice its radius
  done = ~any(G(act,:) == 0 & (1:size(G,2)) <= m(act),2) & (0.95*d(j))^2 > 4*rad2(act);
  act = act(~done);
  if isempty(act), break, end

  r = r0(act) + o(j,1); c = c0(act) + o(j,2);
  q = zeros(size(act));
  in = r >= 1 & r <= szP(1) & c >= 1 & c <= szP(2);
  q(in) = lookup(r(in) + (c(in)-1)*szP(1));
  a = act(q > 0); q = q(q > 0);
  if isempty(a), continue, end

  [Xa,Ya,Ga,m(a)] = clip(X(a,:),Y(a,:),G(a,:),m(a),XY(q,:) - XY(s(a),:),q);
  K = size(Xa,2);
  if K > size(X,2), X(:,end+1:K) = 0; Y(:,end+1:K) = 0; G(:,end+1:K) = 0; end
  X(a,1:K) = Xa; Y(a,1:K) = Ya; G(a,1:K) = Ga;
  rad2(a) = max((X(a,:).^2 + Y(a,:).^2) .* ((1:size(X,2)) <= m(a)),[],2);
end

end

% -------------------------------------------------------------------------
function [X,Y,G,m] = clip(X,Y,G,m,nv,gen)
% the polygons X,Y with m vertices cut by the half planes nv*v <= |nv|^2/2,
% the new edges along the bisector with site gen (Sutherland-Hodgman)

K = size(X,2);
isV = (1:K) <= m;
D = X.*nv(:,1) + Y.*nv(:,2) - sum(nv.^2,2)/2;
r = find(any(D > 0 & isV,2));
if isempty(r), return, end

n = numel(r);
J = (1:K) + 1; J = repmat(J,n,1); J(J > m(r)) = 1;
J = (1:n).' + (J-1)*n;
X1 = X(r,:); Y1 = Y(r,:); G1 = G(r,:); d1 = D(r,:); isV = isV(r,:);
d2 = d1(J);
t = d1 ./ (d1 - d2);
IX = X1 + t .* (X1(J) - X1);
IY = Y1 + t .* (Y1(J) - Y1);

% vertex j emits itself if inside and the crossing if its edge leaves, or the crossing if its edge enters
in1 = isV & d1 <= 0;
enter = isV & d1 > 0 & d2 <= 0;
X1(enter) = IX(enter); Y1(enter) = IY(enter);
OX = [X1; IX]; OY = [Y1; IY]; OG = [G1; repmat(gen(r),1,K)];
isO = [in1 | enter; in1 & d2 > 0];
OX = reshape(OX,n,[]); OY = reshape(OY,n,[]); OG = reshape(OG,n,[]); isO = reshape(isO,n,[]);

% compact every row
pos = cumsum(isO,2);
mr = pos(:,end);
Kn = max(max(mr),K);
t = find(isO);
row = mod(t-1,n) + 1;
dst = row + (pos(t)-1)*n;
NX = zeros(n,Kn); NY = NX; NG = NX;
NX(dst) = OX(t); NY(dst) = OY(t); NG(dst) = OG(t);
if Kn > K, X(:,end+1:Kn) = 0; Y(:,end+1:Kn) = 0; G(:,end+1:Kn) = 0; end
X(r,:) = NX; Y(r,:) = NY; G(r,:) = NG; m(r) = mr;

end

% -------------------------------------------------------------------------
function [S,Q,P1,P2,isOpen] = facesOf(XY,s,X,Y,G,m)
% the faces of the closed cells towards a site of higher index, in absolute
% coordinates, and which cells are still open

[n,K] = size(X);
isV = (1:K) <= m;
isOpen = any(G == 0 & isV,2);
J = repmat((1:K) + 1,n,1); J(J > m) = 1;
e = find(isV & G > s & ~isOpen);
r = mod(e-1,n) + 1;
e2 = r + (J(e)-1)*n;
S = s(r); Q = G(e);
P1 = [X(e) Y(e)] + XY(S,:);
P2 = [X(e2) Y(e2)] + XY(S,:);

end

% -------------------------------------------------------------------------
function [V,id] = weld(P,epsilon)
% points within epsilon as one vertex: the points of a cell of an epsilon
% grid together, and neighbouring cells whose first points are that close

k = floor(P / epsilon);
k = k - min(k,[],1) + 1;
ny = max(k(:,2)) + 2;
[u,first,grp] = unique(k(:,1) * ny + k(:,2));
R = P(first,:);
i = cell(4,1); j = i;
o = [1 0; 0 1; 1 1; 1 -1];
for l = 1:4
  [tf,loc] = ismember(u + o(l,1)*ny + o(l,2),u);
  a = find(tf); b = loc(tf);
  c = vecnorm(R(a,:) - R(b,:),2,2) < epsilon;
  i{l} = a(c); j{l} = b(c);
end
lab = conncomp(graph(vertcat(i{:}),vertcat(j{:}),[],numel(u))).';
[~,f] = unique(lab);
V = R(f,:);
id = lab(grp);

end
