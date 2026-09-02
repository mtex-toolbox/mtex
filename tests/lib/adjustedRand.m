function ari = adjustedRand(C)
% adjusted Rand index of a contingency table

n = sum(C(:));
if n < 2, ari = NaN; return, end

nij = sum(nchoose2(C(:)));
ai  = sum(nchoose2(sum(C,2)));
bj  = sum(nchoose2(sum(C,1)));
ex  = ai*bj/nchoose2(n);

den = 0.5*(ai+bj) - ex;
if den == 0, ari = 1; else, ari = (nij - ex)/den; end

end

function y = nchoose2(x), y = x.*(x-1)/2; end
