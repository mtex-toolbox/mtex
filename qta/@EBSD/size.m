function s = size(obj,dim)
% size of EBSD object

s(1) = numel(obj);
s(2) = sum(length(obj));

if nargin > 1,  s = s(dim); end