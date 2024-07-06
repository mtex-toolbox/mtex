function psi = conv(psi1, psi2, varargin)
% spherical convolution of S2Kernels psi1 with psi2 
%
% Syntax
%   psi = conv(psi1, psi2)
%   psi = conv(psi1, A)
%
% Input
%  psi1, psi2 - @S2Kernel
%  A   - list of Legendre coefficients
%
% Output
%  psi   - @S2Kernel
%
% See also
% S2FunHarmonic/conv SO3FunHarmonic/conv  SO3Kernel/conv 

if nargin == 1, psi2 = psi1; end


% ------------------- convolution with a S2Fun -------------------
% In case psi2 is a S2Fun, convolute the S2Fun with the kernel
% conv is commutative if kernel is included
if isa(psi2,'S2Fun')
  psi = conv(psi2,psi1,varargin{:});
  return
end


% ------------------- convolution with a S2Kernel -------------------
if isnumeric(psi1)
  psi = conv(psi2,psi1,varargin{:});
  return
end

% extract Legendre coefficients of psi1
A1 = psi1.A(:);

% extract Legendre coefficients of psi2
if isnumeric(psi2)
  A2 = psi2(:);
elseif isa(psi2,'S2Kernel') || isa(psi2,'SO3Kernel')
  A2 = psi2.A(:);
  A2 = A2 ./ (2*(0:length(A2)-1)+1).';
end

% multiplication in harmonic domain
l = min(length(A1),length(A2));
psi = S2Kernel(A1(1:l).*A2(1:l));


end
