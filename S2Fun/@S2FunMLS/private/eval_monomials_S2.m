function vals = eval_monomials_S2(v, deg, varargin)

tangent = check_option(varargin, 'tangent');

% evaluate the monomials of degree deg, deg-2, ..., mod(deg,2) on v
% leave out a few since v consists of spherical vectors, thus x^2+y^2+z^2 = 1,
%   hence we dont need <x^2 , y^2, z^2 AND 1> in our basis
x = v.x(:);
y = v.y(:);
z = v.z(:);

N = numel(x);
dim = (deg + 1) * (deg + 2) / 2;

% if the tangent parameter is true, we set the z coordinate to 1 
% NOTE:
% if tangent == true, then also centered == true (S2FunMLS-constructor),
%   thus all nodes in v are close to north pole
if nargin == 3 && tangent
  I = z >= 0;
  z( I) =  1;
  z(~I) = -1;
end

% precompute powers of x and y
xpow = ones(N, deg + 1);
ypow = ones(N, deg + 1);
for k = 1 : deg
  xpow(:, k+1) = xpow(:, k) .* x;
  ypow(:, k+1) = ypow(:, k) .* y;
end

% allocate output
vals = zeros(N, dim);

% r determines whether we use even or odd total degrees
r = mod(deg, 2);

% build the basis block by block:
% for each k = 0,...,deg, the x/y-part is
%   y^k, x*y^(k-1), ..., x^k
% and then we multiply the whole block by z or not
idx = 1;
for k = 0 : deg
  cols = idx : idx + k;

  % compute all monomials of current x/y-degree k
  block = xpow(:, 1:k+1) .* ypow(:, k+1:-1:1);

  % decide whether this block gets multiplied by z
  if mod(r + k, 2) == 1
    block = block .* z;
  end

  vals(:, cols) = block;
  idx = idx + k + 1;
end

% improve constant surrogate for odd-degree non-tangent ansatz spaces
%   (use best approximation of the constant function in the ansatz space)
%   (main idea: z = sqrt(1 - x^2 - y^2) = 1 - (x^2 + y^2) / 2 + O(r^4))
if mod(deg,2) == 1 && ~tangent
  m = (deg - 1) / 2;
  r2 = x.^2 + y.^2;
  p0 = ones(N,1);
  term = ones(N,1);
  for j = 1:m
    term = term .* r2;
    % coefficient of (1-r2)^(-1/2)
    cj = nchoosek(2*j,j) / 4^j;
    p0 = p0 + cj .* term;
  end
  vals(:,1) = z .* p0;
end

end