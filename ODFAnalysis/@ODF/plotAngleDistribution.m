function h = plotAngleDistribution(odf,varargin)
% plot axis distribution
%
% Input
%  odf - @ODF
%
% Options
%  resolution - resolution of the plots
%

mtexFig = newMtexFigure(varargin{:}); 

% compute angle distribution
[f,omega] = calcAngleDistribution(odf,varargin{:});

% plot
pPatch = findobj(mtexFig.gca,'Type','patch');
pBar = findobj(mtexFig.gca,'type','bar');

if ~isempty(pPatch)
  faktor = 100 / mean(f) / size(get(pPatch(1),'faces'),1);
elseif ~isempty(pBar)
  faktor = 100 / mean(f) / size(get(pBar(1),'XData'),2);
else
  faktor = 1;
end

h = optiondraw(plot(omega/degree,faktor * max(0,f),'parent',mtexFig.gca),...
  'LineWidth',2,varargin{:});

xlabel(mtexFig.gca,'orientation angle in degree')

if nargout == 0, clear h; end