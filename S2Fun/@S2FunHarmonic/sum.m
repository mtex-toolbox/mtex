function value = sum(sF, varargin)
% calculates the integral for an univariate S2Fun of sums up along a specified dimension fo a multimodal S2Fun
% Syntax
%  value = mean(sF)
%  sF = mean(sF, d)
%
% Options
%   d - dimension to take the sum over
%

if nargin == 1
  value = 4*pi*mean(sF);
else
  sF.fhat = sum(sF.fhat, varargin{1}+1);
  value = sF;
end

end
