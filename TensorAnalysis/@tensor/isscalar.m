function out = isscalar(T,varargin)
% returns the number of tensors

sT = size(T.M);
out = (ndims(T.M)==T.rank) || all(sT(T.rank+1:end)==1);

end