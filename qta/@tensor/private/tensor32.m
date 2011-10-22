function M = tensor32(A)

%b = [1 5 9 6 3 2];
%A = bsxfun(@plus,(0:2)'*9,b);
%M = M(A);
%M(:,4:end) = M(:,4:end)*2;

M = zeros(3,6);
for i=1:3
  for j=1:3
    for k=1:3
      
      if j == k
        n = j;
      else
        n = 9-k-j;
      end
      
      M(i,n) = M(i,n) + A(i,j,k);
    end
  end
end
