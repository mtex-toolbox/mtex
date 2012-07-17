function pl = smooth(p,iter,varargin)
% constrait laplacian smoothing of grains
%


if nargin <2 || isempty(iter)
  iter = 1;
end

pl = polyeder(p);

hpl = {pl.Holes};
hs = cellfun('prodofsize',hpl);
pl = [pl [hpl{:}]];

n = numel(p);
Vertices = get(pl,'Vertices');
VertexIds = get(pl,'VertexIds');
Faces = get(pl,'Faces');

hull = check_option(varargin,'hull');

nv = max(cellfun(@max,VertexIds)); % number of vertices
V = NaN(nv,3);
F = []; i = []; j=[]; l1 = [];
for k=1:n
  v = VertexIds{k};
  vrt = Vertices{k};
  V(v,:) = vrt;
  F = [F ; v(Faces{k})];
  
  if hull
    if size(vrt,1) > 3
      try
        T = convhulln(vrt);
        l1 = [l1; v(unique(T(:)))];
      catch e
      end
    end
  end
end

F = double(F);

F(:,end+1) = F(:,1);
for k=1:size(F,2)-1
  i = [i; F(:,k)];
  j = [j; F(:,k+1)];
end

s = max(i);
E = sparse(i,j,1,s,s);
E = E+E'; % symmetrise

l1 = [l1(:); find(any(triu(E,1)==2 | triu(E,1)>4,2))]; % border % tri-junk

nn = size(V,1);
V = [V;V(l1,:)];
t = nn+numel(l1);

constraits = sparse(double(l1),nn+1:t,1,t,t);
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

weight = get_flag(varargin,{'gauss','expotential','exp','umbrella'},'rate');
lambda = get_option(varargin,weight,1);
for l=1:iter
  if ~strcmpi(weight,'rate')
    [i,j] = find(E);
    d = sqrt(sum((V(i,:)-V(j,:)).^2,2)); % distance
    switch weight
      case 'umbrella'
        w = 1./(d);
        w(d==0) = 1;
      case 'gauss'
        w = exp(-(d./lambda).^2);
      case {'expotential','exp'}
        w = lambda*exp(-lambda*d);
    end
    
    E = sparse(i,j,w,t,t);
  end
  
  %   E = diag(sparse(1./sum(E,2)))*E;
  
  Vt = E*V;
  
  m = sum(E,2);
  m = m(iszero,:);
  
  dV = (V(iszero,:)-Vt(iszero,:)./[m m m]);
  
  V(iszero,:) = V(iszero,:) - lambda*dV;
  
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

