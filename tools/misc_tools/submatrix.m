function B  = submatrix(A,ind)
% B = A(ind) with size as A if possible

if isempty(A) || isempty(ind) || ~any(ind(:))
  B = [];
  return;
end

if length(size(A)) == 3
  for i = 1:size(A,3)
    B(:,:,i) = submatrix(A(:,:,i),ind); %#ok<AGROW>
  end
  return
end

B = A(ind);

if isa(ind,'logical')
  ind = find(ind);
end
[y,x] = ind2sub(size(A),ind);

ny = find(x ~= x(1),1)-1;
if isempty(ny), return;end
nx = round(length(ind) / ny);

if nx*ny ~= length(ind), return;end

x = reshape(x,ny,nx);
y = reshape(y,ny,nx);

if all(equal(x,1)) && all(equal(y,2))  
  B = reshape(B,ny,nx);
end
