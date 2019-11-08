function T = sum(T,dim)
% sum of a list of tensors
%
% Syntax
%   T = sum(T)     % sum along the first non singleton dimension
%   T = sum(T,dim) % sum along dimension dim
%
% Input
%  T - @tensor
%  dim - dimension with respect to which the sum is taken 

if nargin == 1, dim = 1 + (size(T,1) == 1); end
dim = dim + T.rank;
T.M = sum(T.M,dim);
