function b = binom(p,q)
% calculate binomial coefficient

b = prod((p-q+1):p)/prod(1:q);
