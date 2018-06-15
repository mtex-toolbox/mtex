function T = mean(T,dim)
% mean of a list of tensors
%
% Syntax
%  T = mean(T)     % mean along the first non singleton dimension
%  T = mean(T,dim) % mean along dimension dim
%
% Input
%  T - @tensor
%  dim - dimension with respect to which the mean is taken 

if nargin == 1, dim = 1 + (size(T,1) == 1);end
dim = dim + T.rank;
T.M = mean(T.M,dim);
