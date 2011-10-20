function M = tensor23(M)

if all(size(M) == [3 6])
  M(:,4:end) = M(:,4:end)/2;
else
  error('Tensor doesn''t have the right shape');
end

b = [1 6 5 6 2 4 5 4 3];
A = reshape(bsxfun(@minus,b(:)*3,2:-1:0),3,3,3);
M = M(A);