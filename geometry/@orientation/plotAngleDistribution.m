function h = plotAngleDistribution( ori, varargin )
% plot the angle distribution
%
% Input
%  ori - @orientation
%  n   - number of bins
%
% See also
% orientation/plotAxisDistribution
%

mtexFig = newMtexFigure;

% compute omega
maxomega = getMaxAngleFundamentalRegion(ori.CS);

% seach for existing bar plots
h = findobj(mtexFig.gca,'type','bar','-or','type','hgGroup');

if ~isempty(h)
  omega = ensurecell(get(h,'XData'));
  omega = omega{1}*degree;
  
  density = ensurecell(get(h,'YData'));
  density = cellfun(@(x) x(:),density,'UniformOutput',false);
  density = horzcat(density{:},zeros(size(density{1})));
  lg = ensurecell(get(h,'DisplayName'));
  delete(h); % remove old bars
  
else
  % bin size given?
  if ~isempty(varargin) && isscalar(varargin{1})
    bins = varargin{1};
  else
    bins = 20;
  end
  omega = linspace(0,maxomega,bins);
  density = zeros(bins,1);
  lg = {};
end

% compute angle distributions
d = histc(ori.angle,omega).';
density(:,end) = 100 * d ./ sum(d);

h = optiondraw(bar(omega/degree,density,'parent',mtexFig.gca),varargin{:});

% update legend
lg = [lg;{[ori.CS.mineral '-' ori.SS.mineral]}];
for i=1:length(h)
  set(h(i),'DisplayName',lg{i});
end

xlabel(mtexFig.gca,'angle in degree')
ylabel(mtexFig.gca,'percent')
xlim(mtexFig.gca,[0,max(omega)/degree])
%mtexFig.drawNow

if nargout == 0, clear h;end
