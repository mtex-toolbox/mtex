function counts = numNeighbors(grains)
% returns the number of neighboring grains
%
% Input
%  grains - @grain2d
%
% Output
%  counts - number of neighbors per grain
%

% get list of neighbouring grains
pairs = grains.neighbors('full');

% get the number of neighbours per grain
ng = max(grains.id);
countIds = full(sparse(pairs(pairs<=ng),1,1,ng,1));

% rearange with respect to grain order
counts = countIds(grains.id);
