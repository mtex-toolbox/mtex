function vals = eval_monomials_S2(v, deg, varargin)
% eval all monomials of degree deg, deg-2, ..., mod(deg,2) on v
% leave some out since we assume that v are spherical vectors, 
% hence x^2+y^2+z^2 = 1

% get number of points in v and dimension of ansatz space
N = numel(v.x);
dim = (deg + 1) * (deg + 2) / 2;

% tangent is boolean - if true we set the z coordinate to 1 
if nargin == 3 && varargin{1} == true
    v.z = ones(size(z));
end

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
vals = [v.x v.y v.z] .^ exponents;
vals = reshape(vals, N);

end
