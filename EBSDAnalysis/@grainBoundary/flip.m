function gB = flip(gB,ind)
% flip a boundary from phase1/phase2 to phase2/phase1
%
% Syntax
%   gB = flip(gB) % flip all boundaries
%   gB = flip(gB,ind) % flip the boundaries specified in ind
%
% Input
%  gB  - @grainBoundary
%  ind - indeces of the boundaries to flip
%
% Output
%  grains - @grainBoundary
%

if nargin == 2
  gB.ebsdId(ind,:) = fliplr(gB.ebsdId(ind,:));
  gB.grainId(ind,:) = fliplr(gB.grainId(ind,:));
  gB.phaseId(ind,:) = fliplr(gB.phaseId(ind,:));
  gB.misrotation(ind) = inv(gB.misrotation(ind));
else
  gB.eebsdId = fliplr(gB.ebsdId);
  gB.grainId = fliplr(gB.grainId);
  gB.phaseId = fliplr(gB.phaseId);
  gB.misrotation = inv(gB.misrotation);
end