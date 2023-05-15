function calcVariants(job,varargin)
% compute variants, packet Ids and bain Ids
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


%% --- AAG EDIT ---
% compute variantId, packetId and bainId
% % hklParent1 = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},job.p2c.CS);
% % hklChild1  = Miller(1,0,1,job.p2c.SS);
% %
% % hklParent2 = Miller({0,0,1},{1,0,0},{0,1,0},job.p2c.CS);
% % hklChild2  = Miller(1,0,0,job.p2c.SS);
% %
% % [vId, pId,bId] = calcVariantId(parentOri,childOri,job.p2c,...
% %     'packet', hklParent1,hklChild1,...
% %     'bain', hklParent2,hklChild2);

[vId, pId,bId] = calcVariantId(parentOri,childOri,job.p2c,varargin{:});


% store it in the job class
job.variantId(isTr) = vId;
job.packetId(isTr) = pId;
job.bainId(isTr) = bId;
%% --- AAG EDIT ---

% adjust parent and child orientations such that the misorientation is
% closest to the given OR job.p2c
job.grains('id',job.mergeId(isTr)).meanOrientation = ...
    parentOri.project2FundamentalRegion .* inv(variants(job.p2c,vId)) * job.p2c;

