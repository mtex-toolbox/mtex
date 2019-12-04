function SO3F = conv(SO3F1,SO3F2,varargin)
% convolution with a function or a kernel on SO(3) 
%
% Syntax
%   SO3F = conv(SO3F1,SO3F2)
%   SO3F = conv(SO3F1,psi)
%
% Input
%  SO3F1, SO3F2 - @SO3FunHarmonic
%  psi  - convolution @SO3Kernel
%
% Output
%  SO3F - @SO3FunHarmonic
%
% See also
% 

% convolution with a kernel function
if isa(SO3F2,'SO3Kernel')

  SO3F = SO3F1;
  L = SO3F.bandwidth;
  
  A = SO3F2.fhat;
  A(end+1:L+1) = 0;

  % multiply Fourier coefficients of odf with Chebyshev coefficients
  for l = 0:L
    SO3F.fhat(deg2dim(l)+1:deg2dim(l+1)) = ...
      A(l+1) * SO3F.fhat(deg2dim(l)+1:deg2dim(l+1));
  end
else
  
  % ensure second input is harmonic as well
  SO3F2 = SO3FunHarmonic(SO3F2);
end

% get bandwidth
L = min(SO3F1.bandwidth,SO3F2.bandwidth);

% compute Fourier coefficients of mdf
fhat = [SO3F1.fhat(1) * SO3F2.fhat(1); zeros(deg2dim(L+1)-1,1)];
for l = 1:L
  ind = deg2dim(l)+1:deg2dim(l+1);
  fhat(ind) = reshape(SO3F2.fhat(ind),2*l+1,2*l+1) * ...
    reshape(SO3F1.fhat(ind),2*l+1,2*l+1)' ./ (2*l+1);
end

% construct SO3FunHarmonic
SO3F = SO3FunHarmonic(fhat,SO3F2.SRight,SO3F1.SRight);

end

