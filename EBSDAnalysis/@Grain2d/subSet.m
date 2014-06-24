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

grains = subSet@GrainSet(grains,ind);

grains.boundaryEdgeOrder = grains.boundaryEdgeOrder(ind);
