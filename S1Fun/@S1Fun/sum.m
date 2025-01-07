function value = sum(sF, varargin)
% Calculates the integral of a S1Fun based on
% 
% $$ v = \int_{0}^{2\pi} f( o ) do $$
% 
% If there is a second argument it sums up along a specified dimension of a 
% vector-valued S1Fun.
%
% Syntax
%   value = sum(sF)
%   sF = sum(sF, d)
%
% Input
%  sF - @S1Fun
%  d  - dimension to take the sum value over
%
% Output
%  sF  - @S1Fun
%  value - double
%
% Description
%
% SF is a 3x3 S1Fun
% sum(sF) returns a 3x3 matrix with the integrals of each function
% sum(sF, 1) returns a 1x3 S1Fun which contains the pointwise sums along the first dimension
%


if nargin == 1 || ~isnumeric(varargin{1})
  value = 2*pi*mean(sF,varargin{:});
else
  d = varargin{1}+1;
  value = S1FunHandle(@(o) sum(sF.eval(o),d));
end

end