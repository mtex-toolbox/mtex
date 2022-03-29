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

if nargin == 1, psi2 = psi1; end

% In case psi2 is a SO3Fun, convolute the SO3Fun with the kernel
if isa(psi2,'SO3Fun')
  psi = conv(psi2,psi1);
  return
end


L = min(psi1.bandwidth,psi2.bandwidth);     
l = (0:L).';

psi = kernel(psi1.A(1:L+1) .* psi2.A(1:L+1) ./ (2*l+1));
      
end