function CGT = ClebschGordanTensor(j)

A = [[1 1 -1];[1 1 1];[-1 1 1]];
cg = zeros(3,3,2*j+1);
for m1=-1:1
  for m2 = -1:1
    if abs(m1+m2) <= j
      cg(2+m1,2+m2,1+j+m1+m2) = A(2+m1,2+m2) * ClebschGordan(1,1,j,m1,m2,m1+m2);
    end
  end
end

CGT = tensor(cg);


