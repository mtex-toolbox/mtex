function value = sum(sF, varargin)
% calculates the integral for an univariate S1Fun or sums up along a 
% specified dimension for a multimodal S1Fun
%
% Syntax
%   value = sum(sF)
%   sF = sum(sF, d)
%
% Input
%  sF - @S1FunHarmonic
%  d - dimension to take the sum value over
%
% Output
%  sF - S1FunHarmonic
%  value - double
%
% Description
%
% sF is a 3x3 S1Fun
% sum(sF) returns a 3x3 matrix with the integrals of each function
% sum(sF, 1) returns a 1x3 S1Fun wich contains the pointwise sums along the
% first dimension
%

if nargin == 1
  value = 2*pi*mean(sF);
else
  sF.fhat = sum(sF.fhat, varargin{1}+1);
  value = sF;
end

end
