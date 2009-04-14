function out = equal(A,dim)
% check all elements of A to be equal

%make dim first dimension
A = shiftdim(A,dim-1);
A = reshape(A,size(A,1),[]);

B = repmat(A(1,:),size(A,1),1);

out = all(A == B);
