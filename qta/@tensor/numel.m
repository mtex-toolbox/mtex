function n = numel(T,varargin)
% returns the number of tensors

if nargin > 1
  
  n = 1;
  
else

  sT = size(T.M);
  n = prod(sT(T.rank+1:end));
  
end