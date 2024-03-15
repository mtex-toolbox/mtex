function grains = triangulate(grains, varargin)
% triangulate surface of 3d grains

[F,id] = triangulateFaces(grains.F);

% trim I_GF
grains.I_GF = grains.I_GF(:,any(grains.I_GF,1));

grains.I_GF = grains.I_GF(:,id);

grains.boundary.F = F;
grains.boundary.grainId = grains.boundary.grainId(id,:);
grains.boundary.phaseId = grains.boundary.phaseId(id,:);
grains.boundary.ebsdId = grains.boundary.ebsdId(id,:);
grains.boundary.misrotation = grains.boundary.misrotation(id);
grains.boundary.id = grains.boundary.id(id);