function h = histogram(grains,varargin)
% grain area weighted histogram
%
% Syntax
%   histogram(grains)      % volume weighted histogram of the grain volume
%
%   prop = grains.equivalentRadius;
%   histogram(grains,prop) % volume weighted histogram of property prop
%
%   histogram(grains,prop,n)    % specify number of bins
%   histogram(grains,prop,bins) % specify bin edges
%
%   h = histogram(grains)
%
% Input
%  grains - @grain3d
%  n      - number of bin edges, default is 15, (number of bins is n-1)
%  bins   - vector of bin edges
%
% Output
%  h - handle to the histogram graphics object
%

% extract volume and maybe an additional property
volume = grains.volume;
if nargin>1 && isnumeric(varargin{1}) && length(varargin{1}) == length(grains)
  prop = varargin{1};
  varargin(1) = [];
else
  prop = volume;
end

% generate bins
if ~isempty(varargin) && isnumeric(varargin{1})
  if isscalar(varargin{1})
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
h = gobjects(1,numel(grains.indexedPhasesId));
for k = 1:numel(grains.indexedPhasesId)
 
  id = grains.indexedPhasesId(k);
  % find for each area the binId
  [~,~,binId] = histcounts(prop(grains.phaseId==id),bins);
  if any(~binId,'all')
    warning([num2str(nnz(~binId)) ' grains outside bin limits not plotted!']);
  end
  
  % compute the sum of areas belonging to the same bin  
  volumePhase = volume(grains.phaseId==id);
  cumArea = accumarray(binId(binId>0),volumePhase(binId>0),[length(bins)-1 1]) ./ sum(volume);
  
  h(k) = optiondraw( histogram('BinEdges',bins,'BinCounts',cumArea,...
    'FaceColor',grains.colorList(id,:)),varargin{:});
  if h(k).DisplayStyle == "stairs"
    h(k).EdgeColor = grains.CSList{id}.color;
  end
  hold on
  
end
hold off

% labels and title
if all(prop == volume)
  title('grain volume distribution')
  xlabel('grain volume');
end
yticklabels(yticks*100)
ylabel('relative volume (%)')

% legend
min = grains.mineralList(grains.indexedPhasesId);
legend(min{:})

if nargout == 0, clear h; end