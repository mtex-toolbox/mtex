function gB = subSet(gB,ind)
% restrict boundary
%
% Input
%  gB  - @grainBoundary
%  ind - indices
%
% Output
%  gB - @grainBoundary
%

gB.F = gB.F(ind,:);
gB.ebsdId = gB.ebsdId(ind,:);
gB.grainId = gB.grainId(ind,:);
gB.phaseId = gB.phaseId(ind,:);
gB.misrotation = gB.misrotation(ind);

% properties
gB = subSet@dynProp(gB,ind);

% restrict triple points
tP = gB.triplePoints;
if ~isempty(tP)
  gB.triplePoints = subSet(tP,any(gB.I_VF(tP.id,:),2));
end
