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

[mtexFig,isNew] = newMtexFigure(varargin{:});
mtexFig.keepAspectRatio = false;

% compute angles
omega = ori.angle;
maxOmega = maxAngle(ori.CS,ori.SS);

% seach for existing bar plots
h = findobj(mtexFig.gca,'type','bar','-or','type','hgGroup');

if ~isempty(h)
       
  midPoints = ensurecell(get(h,'XData'));
  midPoints= midPoints{1}*degree;
  bins = [2*midPoints(1)-midPoints(2),midPoints,2*midPoints(end)-midPoints(end-1)];
  bins = (bins(1:end-1) + bins(2:end))/2;
  density = ensurecell(get(h,'YData'));
  density = cellfun(@(x) x(:),density,'UniformOutput',false);
  density = horzcat(density{:});
  lg = ensurecell(get(h,'DisplayName'));
  delete(h); % remove old bars
  
  % add a new column
  density(:,end+1) = 0;
    
  % maybe we have to enlarge bins
  if maxOmega > max(bins)
    bins = 0:(bins(2)-bins(1)):maxOmega + 0.01;
    density(end+1:length(bins)-1,:) = 0;    
  end

else
 
  % bin size given?
  if ~isempty(varargin) && isscalar(varargin{1})
    nbins = varargin{1};
  else
    nbins = 19;
  end

  % compute bins  
  bins = linspace(-eps,maxOmega+0.01,nbins);
  density = zeros(nbins-1,1);
  lg = {};
end

% compute angle distributions
d = histc(omega,bins).';
midPoints = 0.5*(bins(1:end-1) + bins(2:end));
density(:,end) = 100 * d(1:end-1) ./ sum(d);


h = optiondraw(bar(midPoints/degree,density,'parent',mtexFig.gca),varargin{:});
xlim(mtexFig.gca,[0,max(bins)/degree])

% update legend
lg = [lg;{[ori.CS.mineral '-' ori.SS.mineral]}];
for i=1:length(h)
  set(h(i),'DisplayName',lg{i});
end

if isNew
  xlabel(mtexFig.gca,'angle in degree')
  ylabel(mtexFig.gca,'percent')
  mtexFig.drawNow(varargin{:})
end

if nargout == 0, clear h;end
