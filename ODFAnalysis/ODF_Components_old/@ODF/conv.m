function odf = conv(odf,A,varargin)
% convolute ODF with kernel psi
%
% Input
%  odf - @ODF
%  A   - Legendre coefficients 
%  psi - convolution @kernel
%
% See also
% ODF_calcFourier ODF_Fourier


if isa(A,'kernel'), A = A.A; end

% convert to Fourier ODF
L = length(A)-1;
odf = FourierODF(odf,min(L,odf.bandwidth));

odf.components{1} = conv(odf.components{1},A);
