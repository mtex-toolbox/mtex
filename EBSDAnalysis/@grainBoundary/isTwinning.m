function ind = isTwinning(gB, mori, threshold )
% find the boundary segments with a given twinning misorientation
%
% Syntax
%
%   ind = isTwinning(gB,mori)                 % within 5 degree of mori
%   ind = isTwinning(gB,CSL(3,cs),2*degree)   % within 2 degree of the Sigma 3 misorientation
%
% Input
%  gB        - @grainBoundary
%  mori      - twinning mis@orientation
%  threshold - maximum deviation angle, default 5*degree
%
% Output
%  ind - logical, true for the segments whose misorientation lies within
%  threshold of mori
%
% See also
% CSL grainBoundary/misorientation

if nargin == 2, threshold = 5*degree; end

ind = false(size(gB));

% which phases to use
phase1 = find(gB.CSList == mori.CS);
phase2 = find(gB.CSList == mori.SS);

% cycle through all indexed phase transitions
pairs = allPairs(phase1,phase2);

for ip = 1:size(pairs,1)
      
  indPhase = gB.hasPhaseId(pairs(ip,1),pairs(ip,2));
  if pairs(ip,1) > pairs(ip,2)
    mori_local = inv(mori);
  else
    mori_local = mori;
  end
  ind(indPhase) = min(angle_outer(gB.subSet(indPhase).misorientation,mori_local),[],2)<threshold;

end
