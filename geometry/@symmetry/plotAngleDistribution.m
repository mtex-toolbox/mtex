function h = plotAngleDistribution(CS,varargin)
% plot axis distribution
%
% Input
%  CS - @symmetry
%
% Options
%  resolution - resolution of the plots
%

[mtexFig,isNew] = newMtexFigure(varargin{:}); 
mtexFig.keepAspectRatio = false;

% compute angle distribution
[f,omega] = angleDistribution(CS);

% plot
pPatch = findobj(mtexFig.gca,'Type','patch');
pBar = findobj(mtexFig.gca,'type','bar');

unit = '%';
if ~isempty(pPatch)
  faktor = 100 / mean(f) / size(get(pPatch(1),'faces'),1);
elseif ~isempty(pBar)
  faktor = 100 / mean(f) / size(get(pBar(1),'XData'),2);
elseif check_option(varargin,'percent')
  faktor = 100;
else
  faktor = 1;
  unit = 'mrd';
end

h = optiondraw(plot(omega/degree,faktor * max(0,f),'parent',mtexFig.gca),...
  'LineWidth',2,varargin{:});

if isNew
  xlabel(mtexFig.gca,'Misorientation angle (degrees)');
  ylabel(mtexFig.gca,['Frequency (' unit ')']);
  drawNow(mtexFig,varargin{:});
end

if nargout == 0, clear h; end
