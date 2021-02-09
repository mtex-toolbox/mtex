function ebsd = calcParentEBSD(job)
% reconstruct parent EBSD
%
% Syntax
%   job.calcParentEBSD
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  ebsd - reconstructed parent @EBSD
%
           
% find Ids of grains that are either parent or child phase
isRecData = job.ebsd.phaseId== job.childPhaseId | ...
            job.ebsd.phaseId== job.parentPhaseId;
grainIds = max(1,job.ebsd.grainId);
grainIds(~isRecData) = 1;

% consider only child pixels that have been reconstructed to parent
% grains
isNowParent = job.ebsd.phaseId == job.childPhaseId &...
  job.grains.phaseId(grainIds) == job.parentPhaseId;

% compute parent orientation
[ori,fit] = calcParent(job.ebsd(isNowParent).orientations,...
  job.grains(job.ebsd.grainId(isNowParent)).meanOrientation,job.p2c);

% setup parent ebsd
ebsd = job.ebsd;
ebsd.prop.fit = nan(size(ebsd));
ebsd(isNowParent).orientations = ori;
ebsd.prop.fit(isNowParent) = fit;

end