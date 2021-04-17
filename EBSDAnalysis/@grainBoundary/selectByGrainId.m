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
%  gBSub  - @grainBoundary
%  pairId - gBSub.grainId = grainId(pairId,:)
%  ind    - gBSub = gB(ind)
%

% we sort both ids row-wise 
gBFlip = diff(gB.grainId,[],2) < 0;
idFlip = diff(grainId,[],2) < 0;
gBgrainId = sort(gB.grainId,2);
grainId = sort(grainId,2);

% find grainId in the boundary Ids 
[ind, pairId] = ismember(gBgrainId,grainId,'rows');
  
% remove boundary segments not in grainId
gB = gB.subSet(ind);
pairId = pairId(pairId>0);

% flip to the order given by grainId
gB = flip(gB,xor(gBFlip(ind),idFlip(pairId)));
