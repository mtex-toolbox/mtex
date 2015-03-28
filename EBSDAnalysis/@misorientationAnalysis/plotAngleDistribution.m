function plotAngleDistribution( obj, varargin )
% plot the angle distribution
%
% Input
%  ebsd - @EBSD
%  grains - @grainSet
%
% Flags
%  ODF, MDF     - compute the uncorrelated angle distribution from the MDF
%  uncorrelated - compute the uncorrelated angle distribution from the EBSD
%  data
%
% See also
% EBSD/calcAngleDistribution
%

% get axis
ax = get_option(varargin,'parent',gca);

% get phases
ind = cellfun(@(c) isa(c,'misorientationAnalysis'),varargin);
if any(ind)
  obj2 = varargin{find(ind,1)};
  varargin = varargin(~ind);
else
  obj2 = obj;
end

% bin size given?
if ~isempty(varargin) && isscalar(varargin{1})
  bins = varargin{1};
else
  bins = 20;
end

% only consider indexed data
obj  = subSet(obj,obj.isIndexed);
obj2 = subSet(obj2,obj2.isIndexed);

% split according to phases
phases1 = obj.phase;
ph1 = unique(phases1);

phases2 = obj2.phase;
ph2 = unique(phases2);

[ph, phpos] = unique([ph1,ph2],'first');
for j = 1:numel(ph)
  if ismember(ph(j),ph1)
    objSplit{phpos(j)} = subSet(obj,phases1 == ph(j)); 
  else
    objSplit{phpos(j)} = subSet(obj2,phases2 == ph(j));
  end
  mineral{phpos(j)} = objSplit{phpos(j)}.mineral; %#ok<AGROW>
  if check_option(varargin,{'ODF','MDF'})
    objSplit{phpos(j)} = calcODF(objSplit{phpos(j)},'Fourier','halfwidth',10*degree,varargin{:}); %#ok<AGROW>
  end
end

% all combinations of phases
[ph1,ph2] = meshgrid(phpos(ismember(ph,ph1)),phpos(ismember(ph,ph2)));
ph1 = ph1(tril(ones(size(ph1)))>0);
ph2 = ph2(tril(ones(size(ph2)))>0);

% compute omega
CS = obj.CSList;
phMap = obj.phaseMap;
maxomega = 0;

for j = 1:numel(CS)
  if isa(CS{j},'symmetry') && any(ph == phMap(j))
    maxomega = max(maxomega,CS{j}.maxAngle);
  end
end

if check_option(varargin,{'ODF','MDF'})
  omega = linspace(0,maxomega,bins);
else
  omega = linspace(0,maxomega,bins);
end

% compute angle distributions
f = zeros(numel(omega),numel(ph1));

for i = 1:numel(ph1)

  f(:,i) = calcAngleDistribution(objSplit{ph1(i)},objSplit{ph2(i)},'omega',omega,varargin{:});
  f(:,i) = 100*f(:,i) ./ sum(f(:,i));

  lg{i} = [mineral{ph1(i)} ' - ' mineral{ph2(i)}]; %#ok<AGROW>
end

% plot
if check_option(varargin,{'ODF','MDF'})

  p = findobj(ax,'Type','patch');

  if ~isempty(p)
    faktor = size(f,1) / size(get(p(1),'faces'),1);
  else
    faktor = size(f,1);
  end

  optiondraw(plot(omega/degree,faktor * max(0,f),'parent',ax),'LineWidth',2,varargin{:});
else
  optiondraw(bar(omega/degree,f,'parent',ax),'BarWidth',1.5,varargin{:});
end

xlabel(ax,'misorientation angle in degree')
xlim(ax,[0,max(omega)/degree])
ylabel(ax,'percent')

legend(ax,lg{:},'Location','northwest')
