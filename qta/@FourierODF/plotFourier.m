function plotFourier(odf,varargin)
% plots Fourier coefficients of the odf
%
%% Input
%  odf - @ODF
%
%% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%  logarithmic - logarithmic plot
%
%% See also
% ODF_calcFourier ODF_Fourier

L = get_option(varargin,'bandwidth',bandwidth(odf));

if L > bandwidth(odf), odf = calcFourier(odf,L); end
if L == 0, L = 32;end

odf_hat = Fourier(odf,'bandwidth',L,'l2-normalization');

for l = 0:L
  f(l+1) = norm(odf_hat(deg2dim(l)+1:deg2dim(l+1)));
end

optionplot(0:L,f,varargin{:});

xlabel('harmonic degree');
ylabel('power');
figure(gcf);
