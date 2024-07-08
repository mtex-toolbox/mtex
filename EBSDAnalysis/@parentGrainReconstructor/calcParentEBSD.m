function ebsd = calcParentEBSD(job,varargin)
% reconstruct parent EBSD
%
% Syntax
%   job.calcParentEBSD
%
% Input
%  job - @parentGrainReconstructor
%
% Options
%  exactOR - enforce exact orientation relationship
%
% Output
%  ebsd - reconstructed parent @EBSD
%  ebsd.grainId   - ids to the reconstructed parent grains                       x %                                                                                 12
%  ebsd.variantId - the variantId of the child phase                             <                                                                                    -
%  ebsd.packetId  - the packetId of the child phase                              <                                                                                    -
%  ebsd.fit       - fit of the reconstruction

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
if check_option(varargin,'exactOR')

  ori = calcParent(ebsd(isNowParent).orientations,...
    job.grains(ebsd.grainId(isNowParent)).meanOrientation,job.p2c);
else

  ori = job.grains(ebsd.grainId(isNowParent)).meanOrientation;
 
end


% compute variantId
[vId,pId,~,fit] = calcVariantId(ori, ebsd(isNowParent).orientations,job.p2c);
ebsd.prop.variantId = NaN(size(ebsd));
ebsd.prop.variantId(isNowParent) = vId;
ebsd.prop.packetId = NaN(size(ebsd));
ebsd.prop.packetId(isNowParent) = pId; 

% adjust parent and child orientations such that the misorientation is
% closest to the given OR job.p2c
ori = ori.project2FundamentalRegion .* inv(variants(job.p2c,vId)) * job.p2c;

% setup parent ebsd
ebsd.prop.fit = nan(size(ebsd));
ebsd(isNowParent).orientations = ori;
ebsd.prop.fit(isNowParent) = fit;

end