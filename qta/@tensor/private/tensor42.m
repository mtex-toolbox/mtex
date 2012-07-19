function M = tensor42(M,doubleconvention)

b = [1 5 9 6 3 2];
A = bsxfun(@plus,b(:),(b-1)*9);
M = M(A);

if doubleconvention
  w = (1+((1:6)>3));
  w = w.' * w;
  M = M .* w;
end
