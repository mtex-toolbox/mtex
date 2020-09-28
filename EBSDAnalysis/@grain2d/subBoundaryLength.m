function  sL = subBoundaryLength(grains,varargin)
% subgrain boundary length per grain
%
% Input
%  grains - @grain2d
%
% Output
%  l - number of boundary segments
%
% Syntax
%   l = grains.subBoundaryLength
%


grainIds = grains.innerBoundary.grainId;
grainIds(diff(grainIds,1,2)~=0) = [];

sL = grains.innerBoundary.segLength;


sL = accumarray(grainIds(:,1),sL,[max(grains.id) 1]);

% convert from id to ind
sL = sL(grains.id);