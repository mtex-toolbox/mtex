function pl = smooth(p,iter,mpower)
% smooth grain-set by edge contraction

if nargin <2 || isempty(iter)
  iter = 1;
end

if nargin < 3
  mpower = 0;
elseif mpower > 1
  mpower = 1;
end


pl = polyeder(p);

hpl = {pl.Holes};
hs = cellfun('prodofsize',hpl);
pl = [pl [hpl{:}]];

n = numel(p);
Vertices = get(pl,'Vertices');
VertexIds = get(pl,'VertexIds');
Faces = get(pl,'Faces');

nv = max(cellfun(@max,VertexIds)); % number of vertices
V = NaN(nv,3);
F = []; i = []; j=[];
for k=1:n
  v = VertexIds{k};
  V(v,:) =  Vertices{k};
  F = [F ; v(Faces{k})];
end

F(:,end+1) = F(:,1);
for k=1:size(F,2)-1
  i = [i; F(:,k)];
  j = [j; F(:,k+1)];
end

s = max(i);
E = sparse(i,j,1,s,s);
E = E+E'; % symmetrise

iszero = ~all(isnan(V),2);

for l=1:iter
  
  [i,j] = find(E);
  w = exp(-sqrt(sum((V(i,:)-V(j,:)).^2,2)));
  
  E = sparse(i,j,w.^(l.^mpower),s,s);
  V = E*V;
  
  m = sum(E,2);
  m = m(iszero,:);
  
  V(iszero,:) = V(iszero,:)./[m m m];
  
end

for k=1:n
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

