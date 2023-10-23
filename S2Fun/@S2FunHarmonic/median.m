function value = median(sF, varargin)
% calculates the median value for an univariate S2Fun or calculates the median along a specified dimension for a multimodal S2Fun
%
% Syntax
%   value = median(sF)
%   sF = median(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the median value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%
% Description
%
% If sF is a 3x3 S2Fun then
% median(sF) returns a 3x3 matrix with the median values of each function
% median(sF, 1) returns a 1x3 S2Fun which contains the pointwise median values along the first dimension
%

s = size(sF);
if nargin == 1
  sF = sF.subSet(':');
  value = median(real(sF.fhat(1, :))/sqrt(4*pi));
  value = reshape(value, s);
else
  s = size(sF);
  value = median(sF.fhat(varargin{1}, :), 2);
  value = reshape(value, s);
end

end