function degrees = basis_degrees_SO3(SO3F)

% Polynomial degree represented by every local basis column. The ordering
% matches eval_monomials_SO3 exactly.

L = SO3F.degree;
degrees = zeros(SO3F.dim, 1);
idx = 1;

if SO3F.tangent
  % Tangent monomials are ordered by total b/c/d-degree 0,1,...,L.
  for ell = 0 : L
    blockSize = nchoosek(ell + 2, 2);
    degrees(idx : idx + blockSize - 1) = ell;
    idx = idx + blockSize;
  end
else
  % On S^3 the ansatz contains the parity degrees L,L-2,... . Consecutive
  % k-blocks in eval_monomials_SO3 form one homogeneous degree block of size
  % (ell+1)^2.
  for ell = mod(L,2) : 2 : L
    blockSize = (ell + 1)^2;
    degrees(idx : idx + blockSize - 1) = ell;
    idx = idx + blockSize;
  end
end

end
