function  gB = reorder(gB,varargin)
% nicely reorder grain boundaries

% compute tours through the adjecency matrix
[idV,idE] = EulerTours(gB.A_V);

% remove breaks
id = isnan(idE);
idE(id) = [];
idV(id) = [];

% reorder edges
F = gB.F(idE,:);

% and also all other properties
gB.ebsdId = gB.ebsdId(idE,:);
gB.grainId = gB.grainId(idE,:);
gB.phaseId = gB.phaseId(idE,:);
gB.misrotation = gB.misrotation(idE);

% which needs to be flipped?
flip = F(:,1) ~= idV(:); 

% flip vertices
F(flip,:) = fliplr(F(flip,:));
gB.F = F;