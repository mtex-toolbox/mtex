function component = conv(component,A,varargin)
% convolute ODF with kernel psi
%
% Input
%  odf - @ODF
%  psi - convolution @kernel
%
% See also
% ODF_calcFourier ODF_Fourier

% multiply Fourier coefficients of odf with Chebyshev coefficients

L = component.bandwidth;
A(end+1:L+1) = 0;

for l = 0:L
  component.f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    A(l+1) * component.f_hat(deg2dim(l)+1:deg2dim(l+1));
end
