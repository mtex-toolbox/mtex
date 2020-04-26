function [parentOri, parentId, childId] = calcParent(childOri,parentRef,p2c)
%
% Syntax
%
%   [parentOri, parentId, childId] = calcParent(childOri,parentRef,p2c)
%   [parentOri, parentId, childId] = calcParent(childOri,p2c)
%
% Input
%  childOri  - child @orientation
%  parentRef - parent @orientation
%  p2c       - parent to child mis@orientation
%
% Output
%  parentOri - parent @orientation
%  childId   - child variant Id
%  parentid  - parent variant Id 
%
% Description
%
%

% child x parent
if length(p2c) == 1, p2c = (p2c.SS * p2c * p2c.CS).'; end
  
% compute distance to all possible variants
d = dot_outer(p2c,inv(childOri) .* parentRef,'noSymmetry');

% take the best fit
[~,id] = max(d);
  
[parentId,childId] = ind2sub(size(p2c),id);

% compute parent orientation corresponding to the best fit
parentOri = childOri .* p2c.subSet(id(:));

end