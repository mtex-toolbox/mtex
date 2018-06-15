function grains = hull(grains)
% replace grains by its convex hull

V = grains.V;

for i = 1:length(grains)
  
  ind = convhulln(V(grains.poly{i},:));
    
  grains.poly{i} = grains.poly{i}([ind(:,1);ind(1,1)].');
  
end

end