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

% select by grainId
gBgrainId = sort(gB.grainId,2);
grainId = sort(grainId,2);
  
[ind, pairId] = ismember(gBgrainId,grainId,'rows');
  
gB = gB.subSet(ind);
pairId = pairId(pairId>0);