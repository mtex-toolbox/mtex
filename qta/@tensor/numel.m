function n = numel(T)
% returns the number of tensors

s = size(T.M);
n = prod(s(T.rank+1:end));
