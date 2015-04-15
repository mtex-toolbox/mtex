function h = plotAngleDistribution( gB, varargin )
% plot uncorelated angle distribution for all pairs of phases
%
% Input
%  gB - @grainBoundary
%
% See also
% orientation/calcAngleDistribution
%

[mtexFig,isNew] = newMtexFigure(varargin{:});
mtexFig.keepAspectRatio = false;

% only consider indexed data
gB  = subSet(gB,gB.isIndexed);

% split according to phases
pairs = allPairs(1:numel(gB.phaseMap));

for ip = 1:size(pairs,1)

  gB_ip = gB.subSet(gB.hasPhaseId(pairs(ip,1),pairs(ip,2)));
  
  if isempty(gB_ip), continue; end

  h = plotAngleDistribution(gB_ip.misorientation);
  hold all

end

warning('off','MATLAB:legend:PlotEmpty');
legend(mtexFig.gca,'-DynamicLegend','Location','northwest')
warning('on','MATLAB:legend:PlotEmpty');

if isNew
  xlabel(mtexFig.gca,'Misorientation angle (degrees)');
  ylabel(mtexFig.gca,'Frequency (%)');
  drawNow(mtexFig,varargin{:});
end

if nargout==0, clear h;end
