function gB = flip(gB,ind)
% flip a boundary from phase1/phase2 to phase2/phase1
%
% Syntax
%   gB3 = flip(gB3) % flip all boundaries
%   gB3 = flip(gB3,ind) % flip the boundaries specified in ind
%
% Input
%  gB  - @grain3Boundary
%  ind - indices of the boundaries to flip
%
% Output
%  gB - @grain3Boundary
%

if nargin == 2
  gB.ebsdId(ind,:) = fliplr(gB.ebsdId(ind,:));
  gB.grainId(ind,:) = fliplr(gB.grainId(ind,:));
  gB.phaseId(ind,:) = fliplr(gB.phaseId(ind,:));
  gB.misrotation(ind) = inv(gB.misrotation(ind));
else
  gB.ebsdId = fliplr(gB.ebsdId);
  gB.grainId = fliplr(gB.grainId);
  gB.phaseId = fliplr(gB.phaseId);
  gB.misrotation = inv(gB.misrotation);
end