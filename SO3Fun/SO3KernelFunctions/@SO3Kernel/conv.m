function psi = conv(psi1,psi2)
% convolution between two SO3-kernel functions gives again a SO3-kernel
%
% Syntax
%   psi = conv(psi1,psi2,varargin)
%   psi = conv(psi1,varargin)
%
% Input
%  psi1, psi2 - @SO3Kernel
%
% Output
%  psi - @SO3Kernel
%
% See also
% SO3FunHarmonic/conv

if nargin == 1, psi2 = psi1; end


% ------------------- convolution with a SO3Fun -------------------
% In case psi2 is a SO3Fun, convolute the SO3Fun with the kernel
% conv is commutative if kernel is included
if isa(psi2,'SO3Fun')
  psi = conv(psi2,psi1);
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


% ------------------- convolution with a SO3Kernel -------------------
L = min(psi1.bandwidth,psi2.bandwidth);     
l = (0:L);
psi = SO3Kernel(psi1.A(1:L+1) .* psi2.A(1:L+1) ./ (2*l+1));


end