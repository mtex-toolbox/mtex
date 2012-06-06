function M = tensor24(M,doubleconvention)

if doubleconvention
  w = 1./(1+((1:6)>3));
  w = w.' * w;
  M = M .* w;
end

b = [1 6 5 6 2 4 5 4 3];
A = reshape(bsxfun(@plus,b(:),(b-1)*6),3,3,3,3);
M = M(A);


