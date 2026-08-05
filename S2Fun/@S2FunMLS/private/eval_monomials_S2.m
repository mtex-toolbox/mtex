function vals = eval_monomials_S2(v, deg, varargin)

tangent = check_option(varargin, 'tangent');

% evaluate the monomials of degree deg, deg-2, ..., mod(deg,2) on v
% leave out redundant terms since x^2+y^2+z^2 = 1 on the sphere
x = v.x(:);
y = v.y(:);
z = v.z(:);

N = numel(x);
dim = (deg + 1) * (deg + 2) / 2;

% Tangent monomials ignore the radial variation. Centered coordinates are
% close to the north pole; the sign is retained for antipodal representatives.
if tangent
  I = z >= 0;
  z(I) = 1;
  z(~I) = -1;
end

% precompute powers of x and y
xpow = ones(N, deg + 1);
ypow = ones(N, deg + 1);
for k = 1 : deg
  xpow(:, k+1) = xpow(:, k) .* x;
  ypow(:, k+1) = ypow(:, k) .* y;
end

vals = zeros(N, dim);
r = mod(deg, 2);

% For each x/y degree k the block is y^k, x*y^(k-1), ..., x^k.
% Depending on parity the complete block is multiplied by z.
idx = 1;
for k = 0 : deg
  cols = idx : idx + k;
  block = xpow(:, 1:k+1) .* ypow(:, k+1:-1:1);

  if mod(r + k, 2) == 1
    block = block .* z;
  end

  vals(:, cols) = block;
  idx = idx + k + 1;
end

% For odd non-tangent spaces, improve the first local constant surrogate.
% The truncated expansion approximates 1/z near the north pole.
if mod(deg,2) == 1 && ~tangent
  m = (deg - 1) / 2;
  r2 = x.^2 + y.^2;
  p0 = ones(N,1);
  term = ones(N,1);
  for j = 1:m
    term = term .* r2;
    cj = nchoosek(2*j,j) / 4^j;
    p0 = p0 + cj .* term;
  end
  vals(:,1) = z .* p0;
end

end
