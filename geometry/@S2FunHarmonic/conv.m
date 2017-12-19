function sF = conv(sF, psi)
% spherical convolution of sF with a radial function psi 
%
% Syntax
%  sF = conv(sF, psi)
%  sF = conv(sF, A)
%
% Input
%  sF - @S2FunHarmonic
%  psi - @kernel
%  A - double - list of Legendre coeficients
%

% extract Legendre coefficients
if isa(psi,'double')
  A = psi;  
else
  A = psi.A;
  A = A ./ (2*(0:length(A)-1)+1).';
end
A = A(1:min(sF.M,length(A)));
  
% reduce bandwidth if required
M = length(A)-1;
sF.fhat = sF.fhat(1:(M+1)^2);

% extend coefficients
A = repelem(A,2*(0:M)+1);

% multiplication in harmonic domain
sF.fhat = A .* sF.fhat;

end
