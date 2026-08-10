function degrees = basis_degrees_S2(S2F)

% polynomial or harmonic degree represented by every local basis column

L = S2F.degree;
degrees = zeros(S2F.dim, 1);
idx = 1;

if S2F.tangent
  % tangent monomials are ordered by total x/y-degree 0,1,...,L
  for ell = 0 : L
    degrees(idx : idx + ell) = ell;
    idx = idx + ell + 1;
  end
else
  % spherical polynomial spaces contain degrees with the parity of L; both the
  % monomial and spherical-harmonic bases are ordered in these degree blocks
  for ell = mod(L,2) : 2 : L
    degrees(idx : idx + 2*ell) = ell;
    idx = idx + 2*ell + 1;
  end
end

end
