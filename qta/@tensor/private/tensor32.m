function M = tensor32(M)

b = [1 5 9 6 3 2];
A = bsxfun(@plus,(0:2)'*9,b);
M = M(A);
M(:,4:end) = M(:,4:end)*2;