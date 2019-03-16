function M = tensor24(M,doubleconvention)

% 
sM = size(M);
M = reshape(M,6*6,[]);

% 
if doubleconvention
  w = 1./(1+((1:6)>3));
  w = w.' * w;
  if doubleconvention == 2, w = sqrt(w); end
  w = repmat(w(:),1,size(M,2));
  M = M .* w;
end

b = [1 6 5 6 2 4 5 4 3];
A = reshape(bsxfun(@plus,b(:),(b-1)*6),3,3,3,3);
M = M(A(:),:);

% reshape back
M = reshape(M,[3 3 3 3 sM(3:end)]);
