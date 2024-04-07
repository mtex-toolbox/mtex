function [binId, cumArea] = hist(grains,varargin)
% plot a grain size histogram
%
% Syntax
%   hist(grains)
%   hist(grains,n) % specify the number of bins
%
%   % use an arbitrary property for the histogram
%   hist(grains,grains.equivalentRadius) 
%
%   binId = hist(grains) % returns the bin for each grain
%    
% Input
%   grains - @grain2d
%   n      - number of bins, default is 15
%   

% extract area and maybe an additional property
area = grains.area;
if nargin>1 && isnumeric(varargin{1}) && length(varargin{1}) == length(grains)
  prop = varargin{1};
  varargin(1) = [];
else
  prop = area;
end

if ~isempty(varargin) && isnumeric(varargin{1})
  nbins = varargin{1};
else
  nbins = 15;
end

idList = grains.indexedPhasesId;

bins = linspace(0,max(prop)+eps,nbins);

cumArea = zeros(numel(bins)-1,numel(idList));
binId = zeros(length(grains),1);

% loop through all phases
for id = 1:numel(idList)
  
  phaseId = grains.phaseId==idList(id);
  phaseArea = area(phaseId);
  phaseProp = prop(phaseId);

  % find for each area the binId
  [~,~,binIdLocal] = histcounts(phaseProp,bins);
  binId(phaseId) = binIdLocal;
  
  % compute the sum of areas belonging to the same bin
  for i = 1:numel(bins)-1
    cumArea(i,id) = sum(phaseArea(binIdLocal == i)) ./ sum(area);
  end
  
end

% plot the result as a bar plot
binCenter = 0.5*(bins(1:end-1)+bins(2:end));
binWidth = 1 + 0.5*size(cumArea,2)>1;
b = bar(binCenter,100*cumArea,'BarWidth',binWidth,'FaceColor','flat');

for id = 1:numel(idList)
  b(id).CData = str2rgb(grains.CSList{idList(id)}.color);
end

b.CData
xlim([bins(1),bins(end)])
if all(prop == area)
  title('grain size distribution')
  xlabel('grain area');
end
ylabel('relative area (%)')

min = grains.mineralList(idList);
legend(min{:})

if nargout == 0, clear binId; end