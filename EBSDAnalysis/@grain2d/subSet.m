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
