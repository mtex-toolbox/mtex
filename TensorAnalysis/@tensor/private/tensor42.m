function M = tensor42(M,doubleconvention)

% compute subindices
b = [1 5 9 6 3 2];
A = bsxfun(@plus,b(:),(b-1)*9);

% 
sM = size(M);
M = reshape(M,3^4,[]);
M = M(A,:);

%
if doubleconvention
  w = (1+((1:6)>3));
  w = w.' * w;
  if doubleconvention == 2, w = sqrt(w); end
  w = repmat(w(:),1,size(M,2));
  M = M .* w;
end

% reshape back
M = reshape(M,[6,6,sM(5:end)]);