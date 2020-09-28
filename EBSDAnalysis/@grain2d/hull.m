function grains = hull(grains)
% replace grains by its convex hull

V = grains.V;
F = [];

for i = 1:length(grains)
  
  ind = convhulln(V(grains.poly{i},:));
    
  p = grains.poly{i}([ind(:,1);ind(1,1)].');
  grains.poly{i} = p;
   
  F = [F;[p(1:end-1).',p(2:end).']]; %#ok<AGROW>
  
end

% update boundary
grains.boundary.F = F;
grains.boundary.ebsdId = NaN(size(F));
bs = cellfun(@length,grains.poly);
grains.boundary.grainId = repelem(grains.id,bs-1,1) * [1,0];
grains.boundary.phaseId = [repelem(grains.phaseId,bs-1,1), ones(size(F,1),1)];

% remove triple points
grains.boundary.triplePoints.boundaryId = zeros(0,3);
grains.boundary.triplePoints.grainId = zeros(0,3);
grains.boundary.triplePoints.phaseId = zeros(0,3);
grains.boundary.triplePoints.nextVertexId = zeros(0,3);
grains.boundary.triplePoints.id = zeros(0,1);

% remove innner boundary
grains.innerBoundary = grainBoundary;

% remove inclusions
grains.inclusionId = zeros(size(grains.inclusionId));

end
