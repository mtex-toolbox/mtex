function out = equal(A,dim)
% check all elements of A to be equal

if nargin == 1
  out = isempty(A) || all(A == A(1));
  return;
end

%make dim first dimension
A = shiftdim(A,dim-1);
A = reshape(A,size(A,1),[]);

B = repmat(A(1,:),size(A,1),1);

out = all(A == B);
