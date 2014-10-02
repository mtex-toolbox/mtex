function [d] = diameter(grains)
% diameter of a grain (longest distance between any two vertices of a grain
% boundary)


V = grains.V;
dim = size(V,2);

[v,g] = find(grains.I_VG);

cs = [0; find(diff(g));size(g,1)];

d = zeros(size(grains));

for k=1:size(grains,1)
  Vg = V(v(cs(k)+1:cs(k+1)),:);
  nv = size(Vg,1);
  
  if nv > 100 % if it is a large Vertex-Set, reduce it to its convex hull
    Vg = Vg(convhulln(Vg),:);
    nv = size(Vg,1);
  end

  diffVg = bsxfun(@minus,reshape(Vg,[nv,1,dim]),reshape(Vg,[1,nv,dim]));
  diffVg = sum(diffVg.^2,3);
  
  d(k) = sqrt(max(diffVg(:)));  
end
