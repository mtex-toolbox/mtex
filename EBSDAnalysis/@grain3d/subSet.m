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

% the properties are changed as follows
% I_GF - remove lines to grains not required anymore
% I_GF - keep columns
% F    - remove not needed faces in grain3boundary
% allV - is kept

%properties
grains3 = subSet@dynProp(grains3,ind);

grains3.id = grains3.id(ind);
grains3.phaseId = reshape(grains3.phaseId(ind),[],1);
grains3.grainSize = grains3.grainSize(ind);

grains3.I_GF = grains3.I_GF(ind,:);

[~, boundInd] = find(grains3.I_GF);
boundInd = unique(boundInd);

grains3.I_GF = grains3.I_GF(:,boundInd);
grains3.boundary = subSet(grains3.boundary, boundInd);

end