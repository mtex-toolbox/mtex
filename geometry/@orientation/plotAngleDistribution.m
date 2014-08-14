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

% compute angles
omega = ori.angle;

% seach for existing bar plots
h = findobj(mtexFig.gca,'type','bar','-or','type','hgGroup');

if ~isempty(h)
  bins = ensurecell(get(h,'XData'));
  bins = bins{1}*degree;
  
  density = ensurecell(get(h,'YData'));
  density = cellfun(@(x) x(:),density,'UniformOutput',false);
  density = horzcat(density{:},zeros(size(density{1})));
  lg = ensurecell(get(h,'DisplayName'));
  delete(h); % remove old bars
  
  %TODO: maybe we have to enlarge bins
  
else
  % bin size given?
  if ~isempty(varargin) && isscalar(varargin{1})
    nbins = varargin{1};
  else
    nbins = 20;
  end

  % compute bins
  maxomega = max(omega);
  bins = linspace(0,maxomega,nbins);
  bins = 0.5 .* (bins(2:end)+bins(1:end-1));
  density = zeros(nbins-1,1);
  lg = {};
end

% compute angle distributions
d = histc(omega,bins).';
density(:,end) = 100 * d ./ sum(d);

h = optiondraw(bar(bins/degree,density,'parent',mtexFig.gca),varargin{:});

% update legend
lg = [lg;{[ori.CS.mineral '-' ori.SS.mineral]}];
for i=1:length(h)
  set(h(i),'DisplayName',lg{i});
end

xlabel(mtexFig.gca,'angle in degree')
ylabel(mtexFig.gca,'percent')
%xlim(mtexFig.gca,[0,max(bins)/degree])
mtexFig.drawNow(varargin{:})

if nargout == 0, clear h;end
