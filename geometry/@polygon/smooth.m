function pl = smooth(p,iter,varargin)
% constraint laplacian smoothing of grains 
%


if nargin <2 || isempty(iter)
  iter = 1;
end

pl = polygon(p);

n = numel(pl);

hpl = {pl.Holes};
hs = cellfun('prodofsize',hpl);
pl = [pl [hpl{:}]];


Vertices = {pl.Vertices};
VertexIds = {pl.VertexIds};

hull = check_option(varargin,'hull');

nv = max(cellfun(@max,VertexIds)); % number of vertices
V = NaN(nv,2);
F = []; i = []; j=[]; l1 = [];
for k=1:numel(pl)
  v = VertexIds{k};
  
  vrt = Vertices{k};
  V(v,:) = vrt;
  
  if hull
    if size(vrt,1) > 2
      T = convhulln(vrt);
      l1 = [l1 v(unique(T(:)))];
    end
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


l1 = [l1(:); find(sum(triu(E,1),2)==1 | sum(E,2) > 4)]; % border % tri-junk

nn = size(V,1);
V = [V;V(l1,:)];
t = nn+numel(l1);

constraits = sparse(l1,nn+1:t,1,t,t);
constraits = constraits+constraits';

[i,j] = find(E);
E = sparse(i,j,1,t,t) + constraits;

iszero = ~all(isnan(V),2);
iszero(nn+1:end) = false;

if check_option(varargin,{'second order','second_order','S'})
  E2 = logical(E*E); 
  E2 = E2-diag(diag(E2)); % second order neighbour
  E = E+E2;
end

weight = get_flag(varargin,{'gauss','expotential','exp'},'none');

for l=1:iter
  if ~strcmpi(weight,'none')
    [i,j] = find(E);
    d = sqrt(sum((V(i,:)-V(j,:)).^2,2)); % distance
    switch weight
      case 'gauss'
         v = std(d);
         w = exp(-(d./v).^2);
      case {'expotential','exp'}
        lambda = 0.1;
         w = lambda*exp(-lambda*d);
    end
    
    E = sparse(i,j,w,t,t);
  end
  
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

