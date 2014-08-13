function h = plotAngleDistribution( gB, varargin )
% plot uncorelated angle distribution for all pairs of phases
%
% Input
%  gB - @grainBoundary
%
% See also
% orientation/calcAngleDistribution
%

mtexFig = newMtexFigure;

% only consider indexed data
gB  = subSet(gB,~any(gB.isNotIndexed,2));

% split according to phases
pairs = allPairs(1:numel(gB.phaseMap));

for ip = 1:size(pairs,1)

  gB_ip = gB.subSet(gB.hasPhaseId(pairs(ip,1),pairs(ip,2)));
  
  if isempty(gB_ip), continue; end

  h = plotAngleDistribution(gB_ip.misorientation);
  hold all

end

legend(mtexFig.gca,'-DynamicLegend','Location','northwest')

if nargout==0, clear h;end
