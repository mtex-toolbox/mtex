function T = diag(T)
% convert rank 1 or rank 0 tensor into diagonal rank 2 tensor
%
% Description
% If the input tensor has rank 0 or 1 the resulting tensor will have rank 2
% with the diagonal filled with the input tensor elements. If the input
% tensor has rank at least two the resulting tensor has rank 1 with
% elements being the diagonal of the input tensor.
%
% Synatx
%
%   T = diag(T)
%
% Input
%  T - @tensor
%
% Output
%  T - @tensor
%
% See also
% tensor/trace

d = T.M;

if T.rank == 0
  d = repmat(d(:),1,3).';
else
  d = reshape(d,3,[]);
end

if T.rank <= 1 % make a rank 2 tensor out of it
  
  M = zeros(9,length(T));
  
  M([1 5 9],:) = d;
  
  T = tensor(reshape(M,[3 3 size(T)]),T.CS,'noCheck','rank',2);
  
else % extract the diagonal
  
  % first dimension -> tensor, second dimension -> multiples of the tensor
  M = reshape(T.M,3^T.rank,[]);
  
  % id's of the diagonal
  % id = sub2ind([3,3,...,3],[1 2 3],[1 2 3],...,[1 2 3])
  id = 1+3.^(0:(T.rank-1))*repmat(0:2,T.rank,1);
  
  % extract diagonal and reshape back
  T = tensor(reshape(M(id,:),[3,size(T)]),T.CS,'noCheck','rank',1);
  
end
