function [gB, pairId, ind] = selectByGrainId(gB,grainId)
% select grain boundaries by pairs of grainId
%
% Syntax
%   [gBSub, pairId, ind] = selectByGrainId(gB,grainId)
%
% Input
%  gB      - @grainBoundary
%  grainId - matrix of pairs of grainIds
%
% Output
%  gBSub  - @grainBoundary, its sides in the order of grainId(pairId,:)
%  pairId - gBSub.grainId = grainId(pairId,:)
%  ind    - the segments of gB in gBSub, in the order of gBSub
%

% we sort both ids row-wise 
gBFlip = diff(gB.grainId,[],2) < 0;
idFlip = diff(grainId,[],2) < 0;
gBgrainId = sort(gB.grainId,2);
grainId = sort(grainId,2);

% find grainId in the boundary Ids 
[~, pairId] = ismember(gBgrainId,grainId,'rows');
  
% remove boundary segments not in grainId
ind = find(pairId);
gB = gB.subSet(ind);
pairId = pairId(ind);

% flip to the order given by grainId
[gB,p] = flip(gB,xor(gBFlip(ind),idFlip(pairId)));
pairId = pairId(p);
ind = ind(p);
