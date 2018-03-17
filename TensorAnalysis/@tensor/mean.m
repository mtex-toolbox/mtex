function T = mean(T,dim)
% sum over all tensors allong dimension 1

if nargin == 1, dim = 1;end
dim = dim + T.rank;
T.M = mean(T.M,dim);
