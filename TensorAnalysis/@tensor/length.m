function n = length(T,varargin)
% returns the number of tensors

sT = [size(T.M) 1];
n = prod(sT(T.rank+1:end));

end