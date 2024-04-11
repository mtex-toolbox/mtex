function value = sum(SO3F, varargin)
% Calculates the integral of a SO3FunHarmonic based on
% 
% $$ v = \int f( R ) dR $$
% 
% with $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$.
% 
% If there is a second argument it sums up along a specified dimension of a 
% vector-valued SO3FunHarmonic.
%
% Syntax
%   value = sum(SO3F)
%   SO3F = sum(SO3F, d)
%
% Input
%  SO3F - @SO3FunHarmonic
%  d    - dimension to take the sum value over
%
% Output
%  SO3F  - @SO3FunHarmonic
%  value - double
%
% Description
%
% SO3F is a 3x3 SO3Fun
% sum(SO3F) returns a 3x3 matrix with the integrals of each function
% sum(SO3F, 1) returns a 1x3 SO3Fun which contains the pointwise sums along the first dimension
%

if nargin == 1
  value = 8*pi^2*mean(SO3F,varargin{:});
else
  SO3F.fhat = sum(SO3F.fhat, varargin{1}+1);
  value = SO3F;
end

end