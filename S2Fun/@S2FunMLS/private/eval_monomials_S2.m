function vals = eval_monomials_S2(v, deg, varargin)

% evaluate the monomials of degree deg, deg-2, ..., mod(deg,2) on v
% leave out a few since we v consists of spherical vectors, thus x^2+y^2+z^2 = 1
% hence, we dont need x^2 , y^2, z^2 AND 1 in our basis

v = v(:);
N = numel(v.x);
dim = (deg + 1) * (deg + 2) / 2;

% if the tangent parameter is true, we set the z coordinate to 1 
if nargin == 3 && varargin{1} == true
    v.z = ones(N, 1);
end

% compute the exponents (in each coordinate) of the basis monomials 
r = mod(deg, 2);
exponents = zeros(dim, 3);
idx = 1;
for k = 0 : deg
  l = k + 1;
  temp = [zeros(l,1), nchoosek((1:l)',1), ones(l,1)*(l+1)];
  exponents(idx:idx+k,:) = [diff(temp,1,2) - 1, zeros(l,1)+mod(r+k,2)];
  idx = idx + l;
end

exponents = reshape(exponents', 1, 3, dim);
vals = prod([v.x(:) v.y(:) v.z(:)] .^ exponents, 2);
vals = reshape(vals, N, dim);

end 
