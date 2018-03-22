function d = det(T)
% compute the trace of a rank 2 tensors
%
% Synatx
%
%   d = det(T)
%
% Input
%  d - rank 2 @tensor
%
% Output
%  d - double
%

if T.rank == 2

  d = det3(T.M);
  
else
  error('Trace is only implemented for tensors of rank 2')
end