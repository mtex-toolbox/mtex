function vals = evalMonomialsS2(v,deg,tangent)
% the monomials of degree deg, deg-2, ..., mod(deg,2) on the sphere
%
% x^2+y^2+z^2 = 1 makes every monomial with z^2 redundant, so z appears at
% most linearly. Tangent monomials replace z by its sign: in centered
% coordinates the nodes are close to the north pole, and the sign marks the
% antipodal representatives.

x = v.x(:);
y = v.y(:);
z = v.z(:);
if tangent, z = 1 - 2*(z < 0); end

N = numel(x);

% powers of x and y
xpow = ones(N,deg + 1);
ypow = ones(N,deg + 1);
for k = 1:deg
  xpow(:,k+1) = xpow(:,k) .* x;
  ypow(:,k+1) = ypow(:,k) .* y;
end

% the block of x/y degree k is y^k, x*y^(k-1), ..., x^k, times z if its
% parity differs from the one of deg
vals = zeros(N,(deg + 1) * (deg + 2) / 2);
idx = 0;
for k = 0:deg
  block = xpow(:,1:k+1) .* ypow(:,k+1:-1:1);
  if mod(deg + k,2) == 1, block = block .* z; end
  vals(:,idx+1:idx+k+1) = block;
  idx = idx + k + 1;
end

end
