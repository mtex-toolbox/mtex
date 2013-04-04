function M = tensor32(A,doubleconvention)

%b = [1 5 9 6 3 2];
%A = bsxfun(@plus,(0:2)'*9,b);
%M = M(A);
%M(:,4:end) = M(:,4:end)*2;

if nargin ==2 && doubleconvention
  fac = 2;
else
  fac = 1;
end
  

M = zeros(3,6);
for i=1:3
  for j=1:3
    for k=1:3
      
      if j == k
        n = j;
      else
        n = 9-k-j;
      end
      
      M(i,n) = A(i,j,k);
      if j ~= k, M(i,n) = fac * M(i,n);end
      
    end
  end
end
