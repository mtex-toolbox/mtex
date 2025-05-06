function vals = eval_monomials_S3(ori, deg, varargin)
% interpret ori as points on the sphere S^3 in R^4
% evaluate the monomials of degree deg, deg-2, ..., mod(deg,2) on ori
% due to a^2 + b^2 + c^2 + d^2 = 1 it suffices to consider monomials where the
%   exponent in the last variable is at most 1 and the sum of all exponents
%   equals the maximal degree (mod 2)

N = numel(ori.a);
dim = nchoosek(deg+3, 3);

% if the tangent parameter is true, we set the real part ori.a to 1
if nargin == 3 && varargin{1} == true
    ori.a = ones(size(ori.a));
end

% construct the exponents (in each coordinate) of the basis monomials 
r = mod(deg, 2);
idx = 1;
for k = 0 : deg
  l = k + 2;
  m = nchoosek(l, 2);
  temp = [zeros(m,1) , nchoosek((1:l)',2) , ones(m,1)*(l+1)];
  exponents(idx:idx+m-1,:) = [zeros(m,1)+mod(r+k,2) , diff(temp,1,2) - 1];
  idx = idx + m;
end

exponents = reshape(exponents', 1, 4, dim);
vals = prod(ori.abcd .^ exponents, 2);
vals = reshape(vals, N, dim); 

end 
