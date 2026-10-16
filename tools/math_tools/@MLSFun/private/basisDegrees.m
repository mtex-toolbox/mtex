function degrees = basisDegrees(F)
% the polynomial degree of every basis column, in the order of the basis

L = F.degree;
d = F.domainDim;

if F.tangent
  % tangent monomials of total degree 0,1,...,L in d variables
  ell = 0:L;
  blockSize = arrayfun(@(l) nchoosek(l+d-1,d-1),ell);
else
  % the harmonics of the degrees with the parity of L
  ell = mod(L,2):2:L;
  numUpTo = @(l) (l >= 0) * nchoosek(max(l,0)+d,d);
  blockSize = arrayfun(@(l) numUpTo(l) - numUpTo(l-2),ell);
end

degrees = repelem(ell(:),blockSize(:));

end
