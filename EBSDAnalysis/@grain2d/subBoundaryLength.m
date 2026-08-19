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

sL = grains.innerBoundary.segLength;

% if varargin is a logical use for selection of relevant innerBoundary
if nargin>1 && islogical(varargin{1})
    grainIds = grainIds(varargin{1},:);
    sL = sL(varargin{1});
end

ind = (diff(grainIds,1,2)~=0);
grainIds(ind,:) = [];
sL(ind,:) = [];

sL = accumarray(grainIds(:,1),sL,[max(grains.id) 1]);

% convert from id to ind
sL = sL(grains.id);
