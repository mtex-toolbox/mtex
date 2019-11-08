function v = Gaussian(m,delta,x)
% normal distribution
%
% Syntax
%   f = Gaussian(m,delta)
%   fx = Gaussian(m,delta,x)
%
% Input
%  m - mean
%  delta - standard deviation
%  x - evaluation point
%
% Output
%  f  - function handle
%  fx - f(x)
%

v = @(x) exp(-(x-m).^2./delta^2) ./delta./sqrt(pi);

if nargin == 3, v = v(x); end


end


