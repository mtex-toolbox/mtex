function C = ChebCoeff(odf,varargin)
% return Chebyshev coefficient of odf
%
% Input
%  odf - @ODF
%
% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%
% See also
% ODF_calcFourier ODF_Fourier

L = get_option(varargin,'bandwidth',odf.bandwidth);

odf_hat = Fourier(odf,'bandwidth',L,'l2-normalization');

C = zeros(1,L+1);
for l = 0:L
  C(l+1) = norm(odf_hat(deg2dim(l)+1:deg2dim(l+1))) ./ (2*l+1);
end
