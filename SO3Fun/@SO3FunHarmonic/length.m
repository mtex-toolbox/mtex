function l = length(SO3F)
% overloads length

s = size(SO3F.fhat);
l = prod(s(2:end));
