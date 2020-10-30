function ebsd = project2FundamentalRegion(ebsd,grains)
%

% determine the reference rotation
if nargin == 2 % either as mean grain orientation
  
  refRot = grains.meanRotation;
  
else % or as the last orientation in a grain
  
  isIndexed = ebsd.isIndexed;
  refRot = ebsd.rotations(accumarray(ebsd.grainId(isIndexed),find(isIndexed),[],@max));
  
end

% extract ebsd info
rot = ebsd.rotations;
grainId = ebsd.grainId;
CS = ebsd.CSList;

% perform the projection for each phase seperately
for idPhase = ebsd.indexedPhasesId
  
  thisPhase = ebsd.phaseId == idPhase;
  rot(thisPhase) = project2FundamentalRegion(rot(thisPhase),CS{idPhase},...
    refRot(grainId(thisPhase)));
  
end

% update EBSD orientations  
ebsd.rotations = rot; 
