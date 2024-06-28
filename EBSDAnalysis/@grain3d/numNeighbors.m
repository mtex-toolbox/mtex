function counts = numNeighbors(grains)
% returns the number of neighboring grains
%
% Input
%  grains - @grain3d
%
% Output
%  counts - number of neighbors per grain
%
% See also
% neighbors

% get list of neighboring grains
pairs = grains.neighbors('full');

% get the number of neighbors per grain
ng = max(grains.id);
countIds = full(sparse(pairs(pairs<=ng),1,1,ng,1));

% rearrange with respect to grain order
counts = countIds(grains.id);