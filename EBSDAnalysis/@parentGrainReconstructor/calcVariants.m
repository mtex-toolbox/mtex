function calcVariants(job,varargin)
% compute variants and packet Ids
%
% Syntax
%   job.calcVariants
%

isTr = job.isTransformed;
childOri = job.grainsI(isTr).meanOrientation;
parentOri = job.grains('id',job.mergeId(isTr)).meanOrientation;

% compute variantId and packetId
[job.variantId(isTr), job.packetId(isTr)] = calcChildVariant(parentOri,childOri,job.p2c,varargin);

