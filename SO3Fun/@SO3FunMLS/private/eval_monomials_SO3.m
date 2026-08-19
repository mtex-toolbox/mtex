function vals = eval_monomials_SO3(ori, deg, varargin)

% interpret ori as points on the sphere S^3 in R^4
% evaluate the monomials of degree deg, deg-2, ..., mod(deg,2) on ori
% due to a^2 + b^2 + c^2 + d^2 = 1 it suffices to consider monomials where the
%   exponent in the first variable is at most 1 and the sum of all exponents
%   equals the maximal degree (mod 2)

tangent = check_option(varargin, 'tangent');

a = ori.a(:);
b = ori.b(:);
c = ori.c(:);
d = ori.d(:);

N = numel(a);
dim = nchoosek(deg + 3, 3);

% if the tangent parameter is true, we set the a coordinate to 1
% NOTE:
% if tangent == true, then also centered == true (SO3FunMLS-constructor),
%   thus all nodes in ori are close to the identity
if tangent
  I = a >= 0;
  a( I) =  1;
  a(~I) = -1;
end

% precompute powers of b, c and d
bpow = ones(N, deg + 1);
cpow = ones(N, deg + 1);
dpow = ones(N, deg + 1);
for k = 1 : deg
  bpow(:, k+1) = bpow(:, k) .* b;
  cpow(:, k+1) = cpow(:, k) .* c;
  dpow(:, k+1) = dpow(:, k) .* d;
end

% allocate output
vals = zeros(N, dim);

% r determines whether we use even or odd total degrees
r = mod(deg, 2);

% build the basis block by block:
% for each k = 0,...,deg, the b/c/d-part is
%   d^k, c*d^(k-1), ..., c^k, b*d^(k-1), ..., b^k
% and then we multiply the whole block by a or not
idx = 1;
for k = 0 : deg
  multiply_a = mod(r + k, 2) == 1;

  for ib = 0 : k
    for ic = 0 : (k - ib)
      id = k - ib - ic;
      col = bpow(:, ib+1) .* cpow(:, ic+1) .* dpow(:, id+1);

      if multiply_a
        col = col .* a;
      end

      vals(:,idx) = col;
      idx = idx + 1;
    end
  end
end

% improve constant surrogate for odd-degree non-tangent ansatz spaces
%   (use best approximation of the constant function in the ansatz space)
%   (main idea: a = sqrt(1 - b^2 - c^2 - d^2)
%       = 1 - (b^2 + c^2 + d^2) / 2 + O(r^4))
if mod(deg,2) == 1 && ~tangent
  m = (deg - 1) / 2;
  r2 = b.^2 + c.^2 + d.^2;
  p0 = ones(N,1);
  term = ones(N,1);
  for j = 1:m
    term = term .* r2;
    % coefficient of (1-r2)^(-1/2)
    cj = nchoosek(2*j,j) / 4^j;
    p0 = p0 + cj .* term;
  end
  vals(:,1) = a .* p0;
end

end
