function psi = radon(psi, delta)
% Radon transform of a S2Kernel
%
% Syntax
%   psi = radon(psi)
%
% Input
%  psi  - @S2Kernel
%
% Output
%  psi - @S2Kernel
%

% Description
% The spherical Radon transform is simply a convolution operator with
% a kernel function with Legendre coefficients given by
% 
%         A(n) = (-1)^(n/2) * (n-1)!! / n!!     if n is even
%         A(n) = 0                              if n is odd
%
% where 
% (n-1)!! = 1 * 3 * 5 * ... (n-1)
% n!!     = 2 * 4 * 6 * ... n
%

if nargin == 2
  
  A = sum(legendre0(psi.bandwidth,cos(pi/2+delta)),2);
  
else
  A = zeros(psi.bandwidth+1,1);
  A(1) = 1;
  for n = 2:2:psi.bandwidth
    A(n+1) = -A(n-1) * (n-1)/n;
  end
  
end
  
psi = conv(psi,A);

end