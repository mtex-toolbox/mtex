function t = trace(T)
% compute the traces of a rank 2 tensor
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
  
elseif T.rank == 4
  
  id = [1 11 13 21 25 29 31 41 51 53 57 61 69 71 81];
  
  M = reshape(T.M,81,[]);
  M = M(id,:).' * [1 0.5 0.5 0.5 0.5 0.5 0.5 1  0.5 0.5 0.5 0.5 0.5 0.5 1].';
  
  t = reshape(M,size(T));
  
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