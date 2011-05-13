function pl = smooth(p)
% smooth grain-set by edge attraction

pl = polyeder(p);

n = numel(p);
Vertices = get(pl,'Vertices');
VertexIds = get(pl,'VertexIds');

Faces = get(pl,'Faces');
FacetIds = get(pl,'FacetIds');

nv = max(cellfun(@max,VertexIds)); % number of vertices
nf = max(cellfun(@max,FacetIds)); % number of faces
df = max(cellfun('size',Faces,2)); % dim of faces

V = zeros(nv,3);
F = zeros(nf,df);
for k=1:n
  v = VertexIds{k};
  V(v,:) =  Vertices{k};
  F(FacetIds{k},:) = v(Faces{k});
end

F = F(any(F ~= 0,2),:); % erase nans
F(:,end+1) = F(:,1);

for k=1:df
  E{k} =  F(:,k:k+1);
end
E = vertcat(E{:});


Ve = reshape(V(E,:),[],2,3);

mw = 0;
while abs(mw-1) > 10^-5
  dV = diff(Ve,1,2);
  dist = exp(-sqrt(sum(dV.^2,3)));
  w = exp(cat(3,dist,dist,dist).*dV);
  
  Ve = Ve + cat(2,w,-w); % shifting vertices
  
  mw = min(w(:));
end

uE = unique(E(:));
d = histc(E(:),uE);
fd = sparse(uE,1,d);

for k=1:3
  V(:,k) = full(sparse(E(:),1,Ve(:,:,k))./fd);
end

for k=1:n
  pl(k).Vertices = V(VertexIds{k},:);
end

if isa(p,'grain')
  pl = set(p,'polytope',polytope(struct(pl)));
end


