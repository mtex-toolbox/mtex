function value = sum(sF, varargin)
% calculates the integral for an univariate S2Fun or sums up along a specified dimension fo a multimodal S2Fun
%
% Syntax
%   value = sum(sF)
%   sF = sum(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the sum value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%
% Description
%
% sF is a 3x3 S2Fun
% sum(sF) returns a 3x3 matrix with the integrals of each function
% sum(sF, 1) returns a 1x3 S2Fun wich contains the pointwise sums along the first dimension
%

if nargin == 1
  value = 4*pi*mean(sF);
else
  sF.fhat = sum(sF.fhat, varargin{1}+1);
  value = sF;
end

end
