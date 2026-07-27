function gB = flip(gB,ind)
% flip a boundary from phase1/phase2 to phase2/phase1
%
% Syntax
%   gB = flip(gB) % flip all boundaries
%   gB = flip(gB,ind) % flip the boundaries specified in ind
%
% Input
%  gB  - @grainBoundary
%  ind - indices of the boundaries to flip
%
% Output
%  grains - @grainBoundary
%

% F has to follow, as its column order encodes the walk direction and the
% convention is that grainId(:,1) lies to the left of it
if nargin == 2
  gB.ebsdId(ind,:) = fliplr(gB.ebsdId(ind,:));
  gB.grainId(ind,:) = fliplr(gB.grainId(ind,:));
  gB.phaseId(ind,:) = fliplr(gB.phaseId(ind,:));
  gB.misrotation(ind) = inv(gB.misrotation(ind));
  gB.F(ind,:) = fliplr(gB.F(ind,:));
else
  gB.ebsdId = fliplr(gB.ebsdId);
  gB.grainId = fliplr(gB.grainId);
  gB.phaseId = fliplr(gB.phaseId);
  gB.misrotation = inv(gB.misrotation);
  gB.F = fliplr(gB.F);
end

% flipping reverses the walk, so the segments of each chain now run backwards
gB = gB.order;