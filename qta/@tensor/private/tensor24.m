function M = tensor24(M)

b = [1 6 5 6 2 4 5 4 3];
A = reshape(bsxfun(@plus,b(:),(b-1)*6),3,3,3,3);
M = M(A);
