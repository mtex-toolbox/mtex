function N = perp(v)
% conmpute an vector best orthogonal to a list of directions

M = reshape(double(v),[],3);
[u,~,~] = svd(M'*M);

N = vector3d(u(:,3));
