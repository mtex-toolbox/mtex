function value = mean(sF, varargin)
% calculates the mean value for an univariate S1Fun or calculates the mean 
% along a specified dimension for a multimodal S1Fun
%
% Syntax
%   value = mean(sF)
%   sF = mean(sF, d)
%
% Input
%  sF - @S1FunHarmonic
%  d - dimension to take the mean value over
%
% Output
%  sF - S1FunHarmonic
%  value - double
%
% Description
%
% If sF is a 3x3 S1Fun then
% mean(sF) returns a 3x3 matrix with the mean values of each function
% mean(sF, 1) returns a 1x3 S1Fun wich contains the pointwise means values along the first dimension
%

s = size(sF);
if nargin == 1
  sF = sF.subSet(':');
  value = real(sF.fhat(sF.bandwidth+1, :));
  value = reshape(value, s);
else
  s = size(sF);
  value = sum(sF, varargin{1})./s(varargin{1});
end

end
