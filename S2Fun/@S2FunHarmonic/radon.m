function sF = radon(sF, delta)
% Radon transform of a spherical function
%
% Syntax
%   sF = radon(sF)
%
% Input
%  sF  - @S2FunHarmonic
%
% Output
%  sF - @S2FunHarmonic
%

% Description
% The spherical Radon transform is is simply a convolution operator with
% a kernel function with Legendre coefficients given by
% 
%         A(n) = (-1)^(n/2) * (n-1)!! / n!!     if n is even
%         A(n) = 0                              if n is odd
%
% where 
% (n-1)!! = 1 * 3 * 5 * ... (n-1)
% n!!     = 2 * 4 * 6 * ... n


if nargin == 2
  
  A = sum(legendre0(sF.bandwidth,cos(pi/2+delta)),2);
  
else
  A = zeros(sF.bandwidth+1,1);
  A(1) = 1;
  for n = 2:2:sF.bandwidth
    A(n+1) = -A(n-1) * (n-1)/n;
  end
  
end
  
  
sF = conv(sF,A);