function h = plotAxisDistribution( gB, varargin )
% plot uncorelated angle distribution for all pairs of phases
%
% Input
%  gB - @grainBoundary
%
% See also
% orientation/calcAngleDistribution
%

[mtexFig,isNew] = newMtexFigure(varargin{:});
h = [];

% only consider indexed data
gB  = subSet(gB,gB.isIndexed);

% split according to phases
pairs = allPairs(1:numel(gB.phaseMap));

for ip = 1:size(pairs,1)

  gB_ip = gB.subSet(gB.hasPhaseId(pairs(ip,1),pairs(ip,2)));
  
  if isempty(gB_ip), continue; end
 
  if ~isempty(h), mtexFig.nextAxis; end
  
  h = [h,plotAxisDistribution(gB_ip.misorientation,'doNotDraw','parent',mtexFig.gca,varargin{:})];
  mtexTitle(mtexFig.gca,[gB_ip.mineral{1} ' - ' gB_ip.mineral{2}]);
  
end

if isNew % finalize plot

  set(gcf,'Name','Misorientation Axes Distribution');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  
end

if nargout==0, clear h;end
