function pl = smooth(p,iter,mpower)
% smooth grains by edge contraction
%
%% Options
% constrained  - 
%
%% See also 
% polyeder/smooth
%

if nargin <2 || isempty(iter)
  iter = 1;
end

if nargin <3
  mpower =  0;
elseif mpower > 1
  mpower = 1;
end

pl = polygon(p);

n = numel(pl);

hpl = {pl.Holes};
hs = cellfun('prodofsize',hpl);
pl = [pl [hpl{:}]];


Vertices = {pl.Vertices};
VertexIds = {pl.VertexIds};

nv = max(cellfun(@max,VertexIds));
V = zeros(nv,2);
l3 = [];
for k=1:numel(pl)
  v = VertexIds{k};
  vrt = Vertices{k};
  V(v,:) = vrt;
  if size(vrt,1) > 2
  T = convhulln(Vertices{k});
  
  l3 = [l3 v(unique(T))];
  end
end

i = [VertexIds{:}];
%shift indices
r1 = cumsum(cellfun('prodofsize',VertexIds));
inds = 2:numel(i)+1;
inds(r1) = [1 r1(1:end-1)+1];
j = i(inds); %partner pointel

nd = i == j;
i(nd) = [];
j(nd) = [];

s = max(i);
E = sparse(i,j,1,s,s);
E = E+E'; % symmetrise


l1 = find(sum(triu(E,1),2)==1); % border
l2 = find(sum(E,2) > 4);   % tri-junk

i = [l1(:);l2(:);l3(:)];



nn = size(V,1);
V = [V;V(i,:)];
t = nn+numel(i);

nn2 = t-numel(l3);

constraits = sparse(i,nn+1:t,1,t,t);
constraits = constraits+constraits';

[i,j] = find(E);
E = sparse(i,j,1,t,t) + constraits;

iszero = ~all(isnan(V),2);
iszero(nn+1:end) = false;

for l=1:iter

  [i,j] = find(E);
  
  w = exp(-sqrt(sum((V(i,:)-V(j,:)).^2,2)));
  
  w(i > nn | j > nn) = 1; % weight of constraits  
  w(i > nn2 | j > nn2) = .25; % weight of convex hull constraits
  
  E = sparse(i,j,w.^(l.^mpower),t,t);
  Vt = E*V;

  m = sum(E,2);
  m = m(iszero,:);
  
  V(iszero,:) = Vt(iszero,:)./[m m];
  
end


for k=1:numel(pl)
  pl(k).Vertices = V(VertexIds{k},:);
end

hpl = pl(n+1:end);
cs = [0 cumsum(hs)];
for k=1:numel(p)
  spl = hpl(cs(k)+1:cs(k+1));
  
  if ~isempty(spl)
    pl(k).Holes = spl;
  end
end

