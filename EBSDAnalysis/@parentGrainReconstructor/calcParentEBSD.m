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

% copy prior EBSD
ebsd = job.ebsdPrior;

% find Ids of grains that are either parent or child phase
isRecData = ebsd.phaseId == job.childPhaseId | ...
  ebsd.phaseId == job.parentPhaseId;

% compute new grainIds
ebsd.grainId(ebsd.grainId>0) = job.mergeId(ebsd.grainId(ebsd.grainId>0));

grainIds = max(1,ebsd.grainId);
grainIds(~isRecData) = 1;

% consider only child pixels that have been reconstructed to parent
% grains
isNowParent = ebsd.phaseId == job.childPhaseId &...
  job.grains.phaseId(grainIds) == job.parentPhaseId;

% maybe there is nothing to do
if nnz(isNowParent) == 0, return; end

% compute parent orientation
[ori,fit] = calcParent(ebsd(isNowParent).orientations,...
  job.grains(ebsd.grainId(isNowParent)).meanOrientation,job.p2c);

% compute variantId
vId = calcVariantId(ori, ebsd(isNowParent).orientations,job.p2c);
ebsd.prop.variantId = NaN(size(ebsd));
ebsd.prop.variantId(isNowParent) = vId;

% adjust parent and child orientations such that the misorientation is
% closest to the given OR job.p2c
ori = ori.project2FundamentalRegion .* inv(variants(job.p2c,vId)) * job.p2c;

% setup parent ebsd
ebsd.prop.fit = nan(size(ebsd));
ebsd(isNowParent).orientations = ori;
ebsd.prop.fit(isNowParent) = fit;

end