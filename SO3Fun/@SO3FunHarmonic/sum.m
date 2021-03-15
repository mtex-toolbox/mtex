function value = sum(SO3F, varargin)
% calculates the integral for an univariate SO3Fun or sums up along a
% specified dimension of a multimodal SO3Fun
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
%  SO3F  - SO3FunHarmonic
%  value - double
%
% Description
%
% SO3F is a 3x3 SO3Fun
% sum(SO3F) returns a 3x3 matrix with the integrals of each function
% sum(SO3F, 1) returns a 1x3 SO3Fun wich contains the pointwise sums along the first dimension
%

if nargin == 1
  value = 8*pi^2*norm(SO3F);
else
  SO3F.fhat = sum(SO3F.fhat, varargin{1}+1);
  value = SO3F;
end

end