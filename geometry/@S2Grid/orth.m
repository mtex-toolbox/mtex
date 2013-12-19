function N = orth(S2G)

M = reshape(double(S2G),[],3);
[u,s,v] = svd(M'*M);

N = vector3d(u(:,3));
