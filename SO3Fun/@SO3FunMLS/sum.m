function value = sum(SO3F,d)
% integral of an SO3FunMLS, or the sum along a dimension of a vector valued one
%
% Syntax
%   value = sum(SO3F)
%   SO3F = sum(SO3F,d)
%
% Input
%  SO3F - @SO3FunMLS
%  d    - dimension to sum along
%
% Output
%  value - double, the integral with vol(SO(3)) = 8*pi^2
%  SO3F  - @SO3FunMLS
%
% Description
% For a 3x3 SO3FunMLS, sum(SO3F) returns the 3x3 matrix of the integrals and
% sum(SO3F,1) the 1x3 SO3FunMLS of the pointwise sums along the first dimension.
%

if nargin == 1
  value = 8*pi^2*mean(SO3F);
else
  SO3F.values = sum(SO3F.values,d+1);
  value = SO3F;
end

end
