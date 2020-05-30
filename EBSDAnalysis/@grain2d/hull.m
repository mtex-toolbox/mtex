function grains = hull(grains)
% replace grains by its convex hull

V = grains.V;
F = [];

for i = 1:length(grains)
  
  ind = convhulln(V(grains.poly{i},:));
    
  p = grains.poly{i}([ind(:,1);ind(1,1)].');
  grains.poly{i} = p;
   
  F = [F;[p(1:end-1).',p(2:end).']];
  
end

% update boundary
grains.boundary.F = F;
grains.boundary.ebsdId = NaN(size(F));
bs = cellfun(@length,grains.poly);
grains.boundary.grainId = repelem(grains.id,bs-1,1) * [1,0];
grains.boundary.phaseId = [repelem(grains.phaseId,bs-1,1), ones(size(F,1),1)];
grains.boundary.triplePoints = triplePointList;

end
