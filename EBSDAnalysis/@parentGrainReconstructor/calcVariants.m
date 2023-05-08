function calcVariants(job,varargin)
% compute variants and packet Ids
%
% Syntax
%   job.calcVariants
%
% Input
%   job - @parentGrainReconstructor
%
% Output
%   job.transformedGrains.variantId - variant ids
%   job.transformedGrains.packetId  - packet ids
%

isTr = job.isTransformed;
childOri = job.grainsPrior(isTr).meanOrientation;
parentOri = job.grains('id',job.mergeId(isTr)).meanOrientation;

% % compute variantId and packetId
% [vId, pId] = calcVariantId(parentOri,childOri,job.p2c,varargin{:});

%% AAG ADDED
% compute variantId, packetId and bainId
[vId, pId,bId] = calcVariantId(parentOri,childOri,job.p2c,varargin{:}); 
%% AAG ADDED

% store it in the job class
job.variantId(isTr) = vId;
job.packetId(isTr) = pId;
%% AAG ADDED
job.bainId(isTr) = bId;
%% AAG ADDED

% adjust parent and child orientations such that the misorientation is
% closest to the given OR job.p2c
job.grains('id',job.mergeId(isTr)).meanOrientation = ...
  parentOri.project2FundamentalRegion .* inv(variants(job.p2c,vId)) * job.p2c;

