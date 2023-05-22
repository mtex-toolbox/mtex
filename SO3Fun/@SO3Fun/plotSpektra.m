function plotSpektra(SO3F,varargin)
% visualize the harmonic coefficients
%
% Syntax
%
%   plotSpektra(SO3F)
%   plotSpektra(SO3F,'bandwidth',32)
%
% Input
%  SO3F - @SO3Fun
%
% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%  logarithmic - logarithmic plot
%
% See also
% SO3Fun/calcFourier FourierODF

SO3F = SO3FunHarmonic(SO3F,varargin{:});

[mtexFig,isNew] = newMtexFigure(varargin{:});

L = get_option(varargin,'bandwidth',SO3F.bandwidth);

power = zeros(L+1,numel(SO3F));
LL = min(L,SO3F.bandwidth);
power(1:LL+1,:) = SO3F.power(1:LL+1,:);

optionplot(0:L,power,'Marker','o','linestyle',':',...
  'parent',mtexFig.gca,varargin{:});

if isNew
  xlim(mtexFig.gca,[0,L])
  xlabel(mtexFig.gca,'harmonic degree');
  ylabel(mtexFig.gca,'power');
  drawNow(mtexFig,varargin{:});
end
