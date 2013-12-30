function A = tensor23(M,doubleconvention)

% if all(size(M) == [3 6])
%   M(:,4:end) = M(:,4:end)/2;
% else
%   error('Tensor doesn''t have the right shape');
% end
% 
% b = [1 6 5 6 2 4 5 4 3];
% A = reshape(bsxfun(@minus,b(:)*3,2:-1:0),3,3,3);
% M = M(A);
% 

if nargin == 2 && doubleconvention 
  fac = 2;
else
  fac = 1;
end

A = zeros(3,3,3);
for i = 1:3 
  for j = 1:3
    for k = 1:3
      
      if j == k
        n = j;
      else
        n = 9-k-j;
      end
      
      A(i,j,k) = M(i,n);
      if j ~= k, A(i,j,k) = A(i,j,k)./fac;end
    end
  end
end
