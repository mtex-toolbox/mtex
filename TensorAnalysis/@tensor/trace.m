function T = trace(T)
% compute the trace of a rank 2 tensor
%
% Synatx
%
%   T = trace(T)
%
% Input
%  T - rank 2 tensor
%
% Output
%  T - rank 0 tensor
%

if T.rank == 2
  T = EinsteinSum(T,[-1 -1]);
elseif T.rank > 2
  
  % first dimension -> tensor, second dimension -> multiples of the tensor
  M = reshape(T.M,3^T.rank,[]);
  
  % id's of the diagonal
  % id = sub2ind([3,3,...,3],[1 2 3],[1 2 3],...,[1 2 3])
  id = 1+3.^(0:(T.rank-1))*repmat(0:2,T.rank,1);
  
  % sum up diagonal
  M = sum(M(id,:));
  
  % reshape back
  T.M = reshape(M,size(T));
  T.rank = 0;
  
else
  error('Trace is only implemented for tensors with rank at least 2')
end