function GROD = calcGROD(ebsd,grains)
% compute grain reference orientation deviation / mis2mean
%
% Syntax
%
%   % reconstruct grains
%   [grains, ebsd,grainId] = calcGrains(ebsd('indexed'))
%
%   % compute grain reference orientation deviation
%   GROD = calcGROD(ebsd,grains)
%
% Input 
%  ebsd   - @EBSD
%  grains - @grain2d
%
% Output
%  GROD - @rotation, mis@orientation
%
% See also
%

GROD = rotation.nan(size(ebsd));

for phId = grains.indexedPhasesId
  thisPhase = ebsd.phaseId == phId;
  if ~any(thisPhase), continue; end
  
  meanOri = grains.meanRotation(ebsd.grainId(thisPhase));
  meanOri = project2FundamentalRegion(meanOri, ebsd.CSList{phId}, ebsd.rotations(thisPhase));
  GROD(thisPhase) = inv(meanOri) .* ebsd.rotations(thisPhase);
  
end

if ebsd.isSinglePhase, GROD = orientation(GROD,ebsd.CS,ebsd.CS); end
