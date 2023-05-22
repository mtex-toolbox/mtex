function h = histogram(grains,varargin)
% grain area weighted histogram
%
% Syntax
%   histogram(grains)      % area weighted histogram of the grain area
%
%   prop = grains.equivalentRadius;
%   histogram(grains,prop) % area weighted histogram of property prop
%
%   histogram(grains,prop,n)    % specify number of bins
%   histogram(grains,prop,bins) % specify bin edges
%
%   h = histogram(grains)
%
% Input
%  grains - @grain2d
%  n      - number of bin edges, default ist 15, (number of bins is n-1)
%  bins   - vector of bin edges
%
% Output
%  h - handle to the histogram graphics object
%

[mtexFig,isNew] = newMtexFigure(varargin{:});
mtexFig.keepAspectRatio = false;

% exract area and maybe an aditional property
area = grains.area;
if nargin>1 && isnumeric(varargin{1}) && length(varargin{1}) == length(grains)
  prop = varargin{1};
  varargin(1) = [];
else
    prop = area;
end

% generate bins
if ~isempty(varargin) && isnumeric(varargin{1})
  if numel(varargin{1})==1
    nbins = varargin{1}; %define nbins
  elseif numel(varargin{1})>1
    bins = varargin{1}; %define bin edges automatically
    nbins = numel(varargin{1});
  end
else
  nbins = 15;
end
if ~exist('bins','var'), bins = linspace(0,max(prop)+eps,nbins); end

% loop through all phases
h = [];
for id = grains.indexedPhasesId
    
  % find for each area the binId
  [~,~,binId] = histcounts(prop(grains.phaseId==id),bins);
  if any(~binId,'all')
    warning([num2str(nnz(~binId)) ' grains outside bin limits not plotted!']);
  end
  
  % compute the sum of areas belonging to the same bin
  
  areaPhase = area(grains.phaseId==id);
  cumArea = accumarray(binId(binId>0),areaPhase(binId>0),[length(bins)-1 1],@nansum) ./ sum(area);
  
  h = [h,optiondraw( histogram('BinEdges',bins,'BinCounts',cumArea,...
    'FaceColor',grains.CSList{id}.color),varargin{:})]; %#ok<AGROW>
  if strcmp(get(h,'DisplayStyle'),'stairs')
    set(h(grains.indexedPhasesId==id),'EdgeColor',grains.CSList{id}.color);
  end
  hold on
  
end
hold off

% labels and title
if all(prop == area)
  title(mtexFig.gca,'grain size distribution')
  xlabel(mtexFig.gca,'grain area');
end
yticklabels(mtexFig.gca,yticks*100)
ylabel(mtexFig.gca,'relative area (%)')

% legend
min = grains.mineralList(grains.indexedPhasesId);
legend(min{:})

if isNew, mtexFig.drawNow(varargin{:});end

if nargout == 0, clear h; end