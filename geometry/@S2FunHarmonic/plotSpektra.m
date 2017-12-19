function plotSpektra(sF,varargin)
% plots Fourier coefficients of a spherical function
%
% Syntax
%
%   plotSpectra(sF)
%
% Input
%  sF - @S2Fun
%
% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%  logarithmic - logarithmic plot
%

[mtexFig,isNew] = newMtexFigure(varargin{:});

M = get_option(varargin,'bandwidth',sF.M);

m = repelem(0:M,2*(0:M)+1);

power = sqrt(accumarray(1+m.',abs(sF.fhat).^2));

optionplot(0:M,power,'Marker','o','linestyle',':',...
  'parent',mtexFig.gca,varargin{:});

if isNew
  xlim(mtexFig.gca,[0,M])
  xlabel(mtexFig.gca,'harmonic degree');
  ylabel(mtexFig.gca,'power');
  drawNow(mtexFig,varargin{:});
end
