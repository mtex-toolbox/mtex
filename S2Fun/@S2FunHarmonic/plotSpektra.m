function plotSpektra(sF,varargin)
% plots Fourier coefficients of a spherical function
%
% Syntax
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

bandwidth = get_option(varargin,'bandwidth',sF.bandwidth);

m = repelem(0:bandwidth,2*(0:bandwidth)+1);

subs = [kron(ones(length(sF), 1), 1+m.') kron((1:length(sF))', ones(length(m), 1))];

power = sqrt(accumarray(subs,abs(sF.fhat(:)).^2));

optionplot(0:bandwidth,power,'Marker','o','linestyle',':',...
  'parent',mtexFig.gca,varargin{:});

if isNew
  fs = get_option(varargin,'FontSize',getMTEXpref('FontSize'));
  xlim(mtexFig.gca,[0,bandwidth])
  set(mtexFig.gca,'Fontsize',fs);
  xlabel(mtexFig.gca,'harmonic degree','FontSize',fs);
  ylabel(mtexFig.gca,'power','FontSize',fs);
  drawNow(mtexFig,varargin{:});
end
