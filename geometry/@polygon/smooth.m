function pl = smooth(p,iter,varargin)
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

pl = polygon(p);

n = numel(pl);

hpl = {pl.Holes};

hs = cellfun('prodofsize',hpl);

pl = [pl [hpl{:}]];


Vertices = {pl.Vertices};
VertexIds = {pl.VertexIds};



nv = max(cellfun(@max,VertexIds));
V = zeros(nv,2);
for k=1:numel(pl)
  V(VertexIds{k},:) = Vertices{k};
end


E = cellfun(@(x) [x(1:end)' x([2:end 1])']  ,VertexIds(:),'uniformoutput',false);
E = vertcat(E{:});


ls = size(V,1);

% if check_option(varargin,'constrained')
  u  = unique(E);
  E = [E; ...
    [u(:)+ls u(:)];
    [u(:) u(:)+ls]]; % constrained
  V = [V; V];
% end


  uE = unique(E(:));
  fd = sparse(uE,1,histc(E(:),uE));

for l=1:iter
  Ve = reshape(V(E,:),[],2,2);
  dV = diff(Ve,1,2);
  
  dist = exp(-sqrt(sum(dV.^2,3)));
  w = cat(3,dist,dist).*dV;
  
  Ve = Ve + cat(2,w,-w); % shifting vertices
    
  for k=1:2
    T = full(sparse(E(:),1,Ve(:,:,k))./fd); 
    V(1:ls,k) = T(1:ls);
  end
  
end
%
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

if isa(p,'grain')
  pl = set(p,'polytope',polytope(struct(pl(1:n))));
end
