function CGT = ClebschGordanTensor(m1,m2,M)

%A = [[1 1 -1];[1 1 1];[-1 1 1]];
A = ones(2*m1+1,2*m2+1);
[x,y] = find(A);
A((((x>m1+1) & (y<m2+1)) | ((x<m1+1) & (y>m2+1))) & (~rem(x-m1,2) | ~rem(y-m2,2))) = -1;


%A(1:m1,m2+2:2*m2+1) = -1;
%A(m1+2:2*m1+1,1:m2) = -1;
%A(1,end) = 1;
%A(end,1) = 1;

cg = zeros(2*m1+1,2*m2+1,2*M+1);
for j1=-m1:m1
  for j2 = -m2:m2
    if abs(j1+j2) <= M
      cg(1+m1+j1,1+m2+j2,1+M+j1+j2)...
        = A(1+m1+j1,1+m2+j2) * ClebschGordan(m1,m2,M,j1,j2,j1+j2);
    end
  end
end

CGT = tensor(cg,'rank',3,'noCheck');
%CGT = tensor(cg);

