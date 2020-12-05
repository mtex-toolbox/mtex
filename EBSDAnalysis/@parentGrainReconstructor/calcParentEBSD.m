function ebsd = calcParentEBSD(job)
% update EBSD
           
% consider only child pixels that have been reconstructed to parent
% grains
isNowParent = job.ebsd.phaseId == job.childPhaseId &...
  job.grains.phaseId(max(1,job.ebsd.grainId)) == job.parentPhaseId;

% compute parent orientation
[ori,fit] = calcParent(job.ebsd(isNowParent).orientations,...
  job.grains(job.ebsd.grainId(isNowParent)).meanOrientation,job.p2c);

% setup parent ebsd
ebsd = job.ebsd;
ebsd.prop.fit = nan(size(ebsd));
ebsd(isNowParent).orientations = ori;
ebsd.prop.fit(isNowParent) = fit;

end