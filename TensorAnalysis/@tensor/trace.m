function t = trace(T)
% compute the trace of a rank 2 tensor
%
% Synatx
%
%   t = trace(T)
%
% Input
%  T - @tensor
%
% Output
%  t - double
%

if T.rank == 2
  
  t = EinsteinSum(T,[-1 -1]);
  
elseif T.rank > 2
  
  % first dimension -> tensor, second dimension -> multiples of the tensor
  M = reshape(T.M,3^T.rank,[]);
  
  % id's of the diagonal
  % id = sub2ind([3,3,...,3],[1 2 3],[1 2 3],...,[1 2 3])
  id = 1+3.^(0:(T.rank-1))*repmat(0:2,T.rank,1);
  
  % sum up diagonal
  M = sum(M(id,:));
  
  % reshape back
  t = reshape(M,size(T));
    
else
  error('Trace is only implemented for tensors with rank at least 2')
end