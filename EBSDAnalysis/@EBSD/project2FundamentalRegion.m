function ebsd = project2FundamentalRegion(ebsd,grains)
%

% determine the reference rotation
% refRot is indexed by grain id (not grain array position), so it can be
% looked up directly as refRot(grainId) regardless of which branch below
% was used to construct it
if nargin == 2 % either as mean grain orientation

  refRot = rotation.nan(max(grains.id),1);
  refRot(grains.id) = grains.meanRotation;

else % or as the last orientation in a grain

  isIndexed = ebsd.isIndexed;
  refInd = accumarray(ebsd.grainId(isIndexed),find(isIndexed),[],@max);
  refRot = rotation.nan(length(refInd));
  refRot(refInd>0) = ebsd.rotations(refInd(refInd>0));

end

% extract ebsd info
rot = ebsd.rotations;
grainId = ebsd.grainId;
CS = ebsd.CSList;

% perform the projection for each phase seperately
for idPhase = ebsd.indexedPhasesId

  thisPhase = ebsd.phaseId == idPhase;
  rot(thisPhase) = project2FundamentalRegion(rot(thisPhase),CS(idPhase),...
    refRot(grainId(thisPhase)));

end

% update EBSD orientations  
ebsd.rotations = rot; 
