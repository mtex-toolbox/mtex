function vals = evalMonomialsSO3(ori,deg,tangent)
% the monomials of degree deg, deg-2, ..., mod(deg,2) on the unit quaternions
%
% a^2+b^2+c^2+d^2 = 1 makes every monomial with a^2 redundant, so a appears
% at most linearly. Tangent monomials replace a by its sign: in centered
% coordinates the nodes are close to the identity.

a = ori.a(:);
b = ori.b(:);
c = ori.c(:);
d = ori.d(:);
if tangent, a = 1 - 2*(a < 0); end

N = numel(a);

% powers of b, c and d
bpow = ones(N,deg + 1);
cpow = ones(N,deg + 1);
dpow = ones(N,deg + 1);
for k = 1:deg
  bpow(:,k+1) = bpow(:,k) .* b;
  cpow(:,k+1) = cpow(:,k) .* c;
  dpow(:,k+1) = dpow(:,k) .* d;
end

% the block of b/c/d degree k is d^k, c*d^(k-1), ..., c^k, b*d^(k-1), ..., b^k,
% times a if its parity differs from the one of deg
vals = zeros(N,nchoosek(deg + 3,3));
idx = 1;
for k = 0:deg
  for ib = 0:k
    for ic = 0:k-ib
      col = bpow(:,ib+1) .* cpow(:,ic+1) .* dpow(:,k-ib-ic+1);
      if mod(deg + k,2) == 1, col = col .* a; end
      vals(:,idx) = col;
      idx = idx + 1;
    end
  end
end

end
