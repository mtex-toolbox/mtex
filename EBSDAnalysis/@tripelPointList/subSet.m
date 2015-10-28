function tP = subSet(tP,ind)
% restrict boundary
%
% Input
%  tP  - @grainBoundary
%  ind - 
%
% Ouput
%  grains - @grainBoundary
%

tP.V = tP.V(ind,:);
tP.id = tP.id(ind,:);
tP.boundaryId = tP.boundaryId(ind,:);
tP.grainId = tP.grainId(ind,:);
tP.phaseId = tP.phaseId(ind,:);
