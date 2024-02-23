function grains = triangulate(grains, varargin)
% triangulate surface of 3d grains

[F,id] = triangulateFaces(grains.poly);

% trim I_CF
grains.I_CF = grains.I_CF(:,any(grains.I_CF,1));

grains.I_CF = grains.I_CF(:,id);

grains.boundary.poly = F;
grains.boundary.grainId = grains.boundary.grainId(id,:);
grains.boundary.phaseId = grains.boundary.phaseId(id,:);
grains.boundary.ebsdId = grains.boundary.ebsdId(id,:);
grains.boundary.misrotation = grains.boundary.misrotation(id);
grains.boundary.id = grains.boundary.id(id);