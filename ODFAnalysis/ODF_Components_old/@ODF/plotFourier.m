function plotFourier(odf,varargin)
% plots Fourier coefficients of the odf
%
% Syntax
%
%   plotFourier(odf)
%   plotFourier(odf,'bandwidth',32)
%
% Input
%  odf - @ODF
%
% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%  logarithmic - logarithmic plot
%
% See also
% ODF_calcFourier ODF_Fourier

[mtexFig,isNew] = newMtexFigure(varargin{:});

L = get_option(varargin,'bandwidth',32);

if ~isFourier(odf), odf = FourierODF(odf,L); end

power = zeros(L+1,1);
LL = min(L,odf.bandwidth);
power(1:LL+1) = odf.components{1}.power(1:LL+1);

optionplot(0:L,power,'Marker','o','linestyle',':',...
  'parent',mtexFig.gca,varargin{:});

if isNew
  xlim(mtexFig.gca,[0,L])
  xlabel(mtexFig.gca,'harmonic degree');
  ylabel(mtexFig.gca,'power');
  drawNow(mtexFig,varargin{:});
end
