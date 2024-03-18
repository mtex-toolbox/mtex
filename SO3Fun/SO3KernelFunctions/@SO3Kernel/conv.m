function psi = conv(psi1,psi2,varargin)
% convolution of an SO3Kernel function with a function or a kernel on SO(3)
%
% We convolute an SO3Kernel $f$ with another SO3Kernel or an SO3Fun $g$
% by the convolution
%
% $$ (f {*}_L g)(R) = \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot g(q^{-1}\,R) \, dq $$
%
% which in this case is similar to the so caled right sided convolution,
% see SO3FunHarmonic/conv.
%
% The convolution of an SO3Kernel with an S2Kernel or an S2Fun $h$ is
% defined by
%
% $$ (f * h)(\xi) =  \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot h(q^{-1}\,\xi) \, dq $$.
% 
%
% Syntax
%   psi = conv(psi1,psi2)
%   SO3F2 = conv(psi1,SO3F1)
%   sF2 = conv(psi1,sF1)
%   phi2 = conv(psi1,phi1)
%   psi = conv(psi1)
%
% Input
%  psi1, psi2 - @SO3Kernel
%  phi1       - @S2Kernel
%  SO3F1      - @SO3Fun
%  sF1        - @S2Fun
%
% Output
%  psi   - @SO3Kernel
%  SO3F2 - @SO3Fun
%  sF2   - @S2Fun
%  phi2  - @S2Kernel
%
% See also
% SO3FunHarmonic/conv SO3FunRBF/conv S2FunHarmonic/conv S2Kernel/conv

if nargin == 1, psi2 = psi1; end


% ------------------- convolution with a SO3Fun -------------------
% In case psi2 is a SO3Fun, convolute the SO3Fun with the kernel
% conv is commutative if kernel is included
if isa(psi2,'SO3Fun')
  psi = conv(psi2,psi1,varargin{:});
  return
end


% ------------------- convolution with a S2Fun -------------------
if isa(psi2,'S2Fun')
  sF = S2FunHarmonic(psi2);
  L = min(psi1.bandwidth,sF.bandwidth);
  
  fhat = zeros((L+1)^2,1);
  for l = 0:L
    fhat(l^2+1:(l+1)^2) = psi1.A(l+1) * sF.fhat(l^2+1:(l+1)^2) ./ (2*l+1);
  end

  if isa(psi2,'S2FunHarmonicSym')
    warning(['There is no symmetry given for the SO3Kernel function. But for convolution the ' ...
      'right symmetry of the SO3Fun has to be compatible with the symmetry of the S2Fun.'])
  end
  psi = S2FunHarmonic(fhat);
  return
end


% ------------------- convolution with a S2Kernel -------------------
if isa(psi2,'S2Kernel')
  L = min(psi1.bandwidth,psi2.bandwidth);     
  l = (0:L);
  psi = S2Kernel(psi1.A(1:L+1) .* psi2.A(1:L+1) ./ (2*l+1));
  return
end


% ------------------- convolution of SO3Kernels -------------------
if isnumeric(psi1)
  psi = conv(psi2,psi1,varargin{:});
  return
end

% extract Legendre coefficients of psi1
A1 = psi1.A(:);

% extract Legendre coefficients of psi2
if isnumeric(psi2)
  A2 = psi2(:);
else
  A2 = psi2.A(:);
  A2 = A2 ./ (2*(0:length(A2)-1)+1).';
end

% multiplication in harmonic domain
L = min(psi1.bandwidth,psi2.bandwidth);     
psi = SO3Kernel(A1(1:L+1) .* A2(1:L+1));


end