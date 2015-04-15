function hist(grains,varargin)
%
%

[mtexFig,isNew] = newMtexFigure(varargin{:});
mtexFig.keepAspectRatio = false;

if nargin>1 && isnumeric(varargin{1})
  nbins = varargin{1};
else
  nbins = 15;
end

area = grains.area;
idList = grains.indexedPhasesId;

bins = linspace(0,max(area)+eps,nbins);

cumArea = zeros(numel(bins)-1,numel(idList));

for id = 1:numel(idList)
  
  phaseArea = area(grains.phaseId==idList(id));

  % find for each area the binId
  [tmp,binId] = histc(phaseArea,bins);

  % compute the sum of areas belonging to the same bin
  
  for i = 1:numel(bins)-1
    cumArea(i,id) = sum(phaseArea(binId == i)) ./ sum(area);
  end
  
end

% plot the result as a bar plot
binCenter = 0.5*(bins(1:end-1)+bins(2:end));
bar(binCenter,100*cumArea,'BarWidth',1.5,'parent',mtexFig.gca)
xlim(mtexFig.gca,[bins(1),bins(end)])
xlabel(mtexFig.gca,'grain area')
ylabel(mtexFig.gca,'relative volume (%)')
title(mtexFig.gca,'grain size distribution')

min = grains.mineralList(idList);
legend(min{:})

if isNew, mtexFig.drawNow(varargin{:});end
