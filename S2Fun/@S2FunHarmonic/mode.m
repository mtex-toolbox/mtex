function value = mode(sF, varargin)
% calculates the mode value for an univariate S2Fun or calculates the mode along a specified dimension for a multimodal S2Fun
%
% Syntax
%   value = mode(sF)
%   sF = mode(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the mode value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%
% Description
%
% If sF is a 3x3 S2Fun then
% mode(sF) returns a 3x3 matrix with the mode values of each function
% mode(sF, 1) returns a 1x3 S2Fun which contains the pointwise mode values along the first dimension
%

s = size(sF);
if nargin == 1
  sF = sF.subSet(':');
  value = mode(real(sF.fhat(1, :))/sqrt(4*pi));
  value = reshape(value, s);
else
  s = size(sF);
  [~, idx] = max(hist(sF.fhat(varargin{1}, :), 50)); % adjust the number of bins (50) if needed.
  edges = linspace(min(sF.fhat(varargin{1}, :)), max(sF.fhat(varargin{1}, :)), 51);
  value = (edges(idx) + edges(idx + 1)) / 2;
  value = reshape(value, s);
end

end
