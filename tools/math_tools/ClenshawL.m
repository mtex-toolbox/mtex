function s = ClenshawL(c,x)
% Clenshaw algorithmus for evaluating Legendre series
%
% Description
%
% $$ s = \sum_n=0^N c_n P_n(x)$$
%
% Input
%  c - coefficients
%  x - evaluation nodes
%
% Output
%  s - Legendre series
%

% init
c= [c(:);0;0];
dn = zeros(size(x));
d1 = zeros(size(x));
d2 = zeros(size(x));

% use backward tree term recurence
for l = length(c)-2:-1:1
  
  d1 = d2 + (2*l+1)/(l+1) * x .* dn;
  d2 = c(l) - l/(l+1) * dn;
  dn = d1;
  
end

s = d2 + x .* d1;

end