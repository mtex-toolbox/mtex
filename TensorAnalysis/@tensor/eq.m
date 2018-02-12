function b = eq(T1,T2)
% checks whether two tensors are equal

b = false;

% check for equal rank
if T1.rank ~= T2.rank, return;end

% check for equal symetries
if T1.CS ~= T2.CS, return;end

% reshape
M1 = reshape(T1.M,3.^T1.rank,[]);
M2 = reshape(T2.M,3.^T1.rank,[]);

% make expand single dimensions
if size(M1,2) == 1, M1 = repmat(M1,1,size(M2,2));end
if size(M2,2) == 1, M2 = repmat(M2,1,size(M1,2));end
  
% check colmnwise
b = all(abs(M1 - M2)<1e-5,1);
