function value = mean(SO3F, varargin)
% Calculates the mean value of a SO3FunHarmonic by using the first Wigner
% coefficient, i.e.
%
% $$ mean(f) = \hat{f}_0^{0,0} = \frac1{8\pi^2} \int_{SO(3)} f( R ) dR $$,
% 
% where $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$.
% 
% or calculates the mean along a specified dimension of a 
% vector-valued SO3Fun.
%
% Syntax
%   value = mean(SO3F)
%   SO3F  = mean(SO3F, d)
%
% Input
%  SO3F - @SO3FunHarmonic
%  d    - dimension to take the mean value over
%
% Output
%  SO3F  - @SO3FunHarmonic
%  value - double
%
% Description
%
% If SO3F is a 3x3 SO3Fun then
% |mean(SO3F)| returns a 3x3 matrix with the mean values of each function
% |mean(SO3F, 1)| returns a 1x3 SO3Fun which contains the pointwise mean values along the first dimension
%

s = size(SO3F);

% mean along specific dimension
if nargin>1 && isnumeric(varargin{1})
  value = sum(SO3F, varargin{1})./s(varargin{1});
  return
end

SO3F = SO3F.subSet(':');
value = SO3F.fhat(1, :);
value = reshape(value, s);

if isalmostreal(value,'componentwise')
  value = real(value);
end


end