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
grains.phaseId = grains.phaseId(ind);
grains.grainSize = grains.grainSize(ind);

% restrict boundary
if islogical(ind)
  grId = grains.boundary.grainId;
  grId(grId>0) = ind(grId(grId>0));
  indBd = any(grId,2);
else
  indBd = any(ismember(grains.boundary.grainId,ind),2);
end

grains.boundary = subSet(grains.boundary,indBd);
