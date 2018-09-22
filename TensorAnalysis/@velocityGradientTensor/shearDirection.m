function s = shearDirection(L)
% shear direction

[s,~,~] = svd(matrix(L));

s = vector3d(s(:,1));
