function [d] = diameter(grains)
% diameter of a grain in measurement units
% longest distance between any two vertices of the grain boundary

% do extract this as it is much faster
V = grains.V;
poly = grains.poly;

d = zeros(size(grains));

for ig = 1:length(grains)
  
  Vg = V(poly{ig},:);
  
  % if it is a large Vertex-Set, reduce it to its convex hull
  if size(Vg,1) > 100, Vg = Vg(convhulln(Vg),:); end
  
  diffVg = bsxfun(@minus,reshape(Vg,[],1,2),reshape(Vg,1,[],2));
  diffVg = sum(diffVg.^2,3);
  
  d(ig) = sqrt(max(diffVg(:)));  
end
