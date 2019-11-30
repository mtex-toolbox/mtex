function SO3F = conv(SO3F1,SO3F2,varargin)
% convolute ODF with kernel psi
%
% Input
%  SO3F - @SO3FunHarmonic
%  psi  - convolution @SO3Kernel
%
% See also
% ODF_calcFourier ODF_Fourier

% convolution with a kernel function
if isa(SO3F2,'SO3Kernel')

  SO3F = SO3F1;
  L = SO3F.bandwidth;
  
  A = SO3F2.fhat;
  A(end+1:L+1) = 0;

  % multiply Fourier coefficients of odf with Chebyshev coefficients
  for l = 0:L
    SO3F.f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
      A(l+1) * SO3F.f_hat(deg2dim(l)+1:deg2dim(l+1));
  end
end

% get bandwidth
L = min(SO3F1.bandwidth,SO3F2.bandwidth);

% compute Fourier coefficients of mdf
f_hat = [SO3F1.f_hat(1) * SO3F2.f_hat(1); zeros(deg2dim(L+1)-1,1)];
for l = 1:L
  ind = deg2dim(l)+1:deg2dim(l+1);
  f_hat(ind) = reshape(SO3F2.f_hat(ind),2*l+1,2*l+1) * ...
    reshape(SO3F1.f_hat(ind),2*l+1,2*l+1)' ./ (2*l+1);
end

% construct SO3FunHarmonic
SO3F = SO3FunHarmonic(f_hat,SO3F2.SRight,SO3F1.SRight);

end

