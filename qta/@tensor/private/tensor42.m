function M = tensor42(M)

b = [1 5 9 6 3 2];
A = bsxfun(@plus,b(:),(b-1)*9);
M = M(A);
