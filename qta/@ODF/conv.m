function odf = conv(odf,psi,varargin)
% convolute ODF with kernel psi
%
%% Input
%  odf - @ODF
%  psi - convolution @kernel
%
%% See also
% ODF_calcFourier ODF_Fourier


%% Fourier ODF

L = bandwidth(odf);
A = getA(psi);

for l = 0:L
  odf.c_hat(deg2dim(l)+1:deg2dim(l+1)) = A(l+1) / (2*l+1) * odf.c_hat(deg2dim(l)+1:deg2dim(l+1)) ;
end
