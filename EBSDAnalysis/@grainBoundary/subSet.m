function gB = subSet(gB,ind)
% restrict boundary
%
% Input
%  gB - @grainBoundary
%  ind    - 
%
% Ouput
%  grains - @grainBoundary
%

gB.F = gB.F(ind,:);
gB.ebsdId = gB.ebsdId(ind,:);
gB.grainId = gB.grainId(ind,:);
gB.phaseId = gB.phaseId(ind,:);
gB.misrotation = gB.misrotation(ind);
