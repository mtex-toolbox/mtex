function n = normalDirection(L)
% normal direction

[~,~,n] = svd(matrix(L));

n = vector3d(n(:,1));