function  numSec = subBoundarySize(grains,varargin)
% number of subgrain boundary segments
%
% Input
%  grains - @grain2d
%
% Output
%  numSec - number of boundary segments
%
% Syntax
%   numSec = grains.boundarySize
%


grainIds = grains.innerBoundary.grainId;

grainIds(diff(grainIds,1,2)~=0) = [];


numSec = accumarray(grainIds(:,1),1,[max(grains.id) 1]);

% convert from id to ind
numSec = numSec(grains.id);