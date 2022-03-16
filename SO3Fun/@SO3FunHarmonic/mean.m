function value = mean(SO3F, varargin)
% calculates the mean value for an univariate SO3Fun or calculates the mean
% along a specified dimension of a multimodal SO3Fun
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
%  SO3F  - SO3FunHarmonic
%  value - double
%
% Description
%
% If SO3F is a 3x3 SO3Fun then
% mean(SO3F) returns a 3x3 matrix with the mean values of each function
% mean(SO3F, 1) returns a 1x3 SO3Fun which contains the pointwise means values along the first dimension
%

s = size(SO3F);
if nargin == 1
  SO3F = SO3F.subSet(':');
  value = real(SO3F.fhat(1, :));
  value = reshape(value, s);
else
  value = sum(SO3F, varargin{1})./s(varargin{1});
end

end