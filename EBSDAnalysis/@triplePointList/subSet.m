function tP = subSet(tP,ind)
% restrict boundary
%
% Input
%  tP  - @grainBoundary
%  ind - 
%
% Output
%  grains - @grainBoundary
%

tP.id = tP.id(ind,:);
tP.boundaryId = tP.boundaryId(ind,:);
tP.grainId = tP.grainId(ind,:);
tP.phaseId = tP.phaseId(ind,:);
tP.nextVertexId = tP.nextVertexId(ind,:);