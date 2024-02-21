function grains3 = subSet(grains3,ind)
% restrict 3d grains
%
% Input
%  grains - @grain3d
%  ind    - indices
%
% Output
%  grains - @grain3d
%

%properties
grains3 = subSet@dynProp(grains3,ind);

grains3.id=grains3.id(ind);
grains3.phaseId = reshape(grains3.phaseId(ind),[],1);
grains3.grainSize = grains3.grainSize(ind);

grains3.I_CF=grains3.I_CF(ind,:);

[~, boundId] = find(grains3.I_CF);
boundInd = grains3.boundary.id2ind(unique(boundId));

grains3.boundary=subSet(grains3.boundary, boundInd);
end