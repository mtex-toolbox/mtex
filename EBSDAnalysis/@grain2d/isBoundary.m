function out = isBoundary(grains)
% check whether a grain is a boundary grain
%
% Syntax
%
%   out = isBoundary(grains)
%
% Input
%
%  grains - @grain2d
%
% Output
%  out - logical
%

gbId = grains.boundary.grainId;

gbId = gbId(any(gbId == 0,2),:);

gbId = unique(gbId(:,2));

out = ismember(grains.id,gbId);