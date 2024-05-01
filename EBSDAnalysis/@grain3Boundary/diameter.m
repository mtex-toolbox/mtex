function d = diameter(grains)
% diameter of a grain in measurement units
% longest distance between any two vertices of the grain boundary

F = grains.F;
d = zeros(size(grains));

% get the coordinates
V = grains.allV.xyz;

for ig = 1:length(grains)

  Vg = V(F{ig},:);
  
  diffVg = bsxfun(@minus,reshape(Vg,[],1,3),reshape(Vg,1,[],3));
  diffVg = sum(diffVg.^2,3);

  d(ig) = sqrt(max(diffVg(:)));
end
