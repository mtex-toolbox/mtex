function grains = subSet(grains,ind)
% 
%
% Input
%  grains - @grainSet
%  ind    - 
%
% Ouput
%  grains - @grainSet
%

grains = subSet@dynProp(grains,ind);

grains.poly = grains.poly(ind);
grains.id = grains.id(ind);
grains.meanRotation = grains.meanRotation(ind);
grains.phaseId = grains.phaseId(ind);
grains.grainSize = grains.grainSize(ind);

% restrict boundary
idV = false(size(grains.V));
idV(grains.idV) = true;

ind = all(idV(grains.boundary.F),2);
grains.boundary = subSet(grains.boundary,ind);
