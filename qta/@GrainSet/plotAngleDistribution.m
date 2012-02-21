function plotAngleDistribution( grains, varargin )
% plot the angle distribution
%
%% Input
% grains - @GrainSet
%% Flags
% boundary - calculate the misorientation angle at grain boundaries
%% See also
% GrainSet/calcAngleDistribution
%

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

%% make new plot
newMTEXplot;

%% get phases
phases = get(grains,'phase');
ph = unique(phases(phases>0));

% all combinations of phases
[ph1,ph2] = meshgrid(ph);
ph1 = ph1(tril(ones(size(ph1)))>0);
ph2 = ph2(tril(ones(size(ph2)))>0);

%% compute omega

CS = get(grains,'CSCell');
phMap = get(grains,'phaseMap');
maxomega = 0;

for j = 1:length(CS)
  if isa(CS{j},'symmetry') && any(ph == phMap(j))
    maxomega = max(maxomega,get(CS{j},'maxOmega'));
  end
end

omega = linspace(0,maxomega,20);

%% compute angle distributions

f = zeros(numel(omega),numel(ph1));

for i = 1:numel(ph1)
  
  gr1 = subsref(grains,phases == ph1(i));
  gr2 = subsref(grains,phases == ph2(i));
  f(:,i) = calcAngleDistribution(gr1,gr2,'omega',omega,varargin{:});
  
  lg{i} = [get(gr1,'mineral') ' - ' get(gr2,'mineral')]; %#ok<AGROW>
end

%% plot

optiondraw(bar(omega/degree,max(0,f)),'BarWidth',1.5,varargin{:});

xlabel('misorientation angle in degree')
xlim([0,max(omega)/degree])
ylabel('percent')

legend(lg{:})
