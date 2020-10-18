function h = histogram(grains,varargin)
% grain area weighted histogram
%
% Syntax
%   histogram(grains)
%   histogram(grains,n) % specify the number of bins
%
%   % use an arbitrary property for the histogramm
%   histogram(grains,grains.equivalentRadius) 
%
%   h = histogram(grains) 
%    
% Input
%  grains - @grain2d
%  n      - number of bins, default ist 15
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
  nbins = varargin{1};
else
  nbins = 15;
end
bins = linspace(0,max(prop)+eps,nbins);

% loop through all phases
h = [];
for id = grains.indexedPhasesId
  
  % find for each area the binId
  [~,~,binId] = histcounts(prop(grains.phaseId==id),bins);
    
  % compute the sum of areas belonging to the same bin
  cumArea = accumarray(binId,area(grains.phaseId==id),[length(bins)-1 1],@nansum) ./ sum(area);
  
  h = [h,optiondraw( histogram('BinEdges',bins,'BinCounts',cumArea,...
    'FaceColor',grains.CSList{id}.color),varargin{:})]; %#ok<AGROW>
  hold on
  
end
hold off

% labels and title
if all(prop == area)
  title(mtexFig.gca,'grain size distribution')
  xlabel(mtexFig.gca,'grain area');
end
ylabel(mtexFig.gca,'relative area (%)')

% legend
min = grains.mineralList(grains.indexedPhasesId);
legend(min{:})

if isNew, mtexFig.drawNow(varargin{:});end

if nargout == 0, clear h; end