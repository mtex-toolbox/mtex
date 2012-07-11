function n = normal(p)
% face normal of polyeder



p = polyeder(p);

n = cell(size(p,1),1);

for k=1:numel(p)
  
  f = double(p(k).Faces);
  v = p(k).Vertices;
  
  orient = double(sign(p(k).FacetIds));
  
  n{k,1} = cross(v(f(:,1),:)-v(f(:,2),:),v(f(:,1),:)-v(f(:,3),:));
  n{k,1} = bsxfun(@times,n{k},orient);

  if size(f,2) > 3
    n{k,2} = cross(v(f(:,3),:)-v(f(:,4),:),v(f(:,3),:)-v(f(:,1),:));
    n{k,2} = bsxfun(@times,n{k,2},orient);
  end
  
end