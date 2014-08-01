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
gB.id = gB.id(ind);
gB.ebsdId = gB.ebsdId(ind,:);
gB.phaseId = gB.phaseId(ind,:);

%gB.isInt = false(0,0) 
%gB.misRotation = rotation
