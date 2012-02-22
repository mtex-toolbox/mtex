function plotAngleDistribution( ebsd, varargin )
% plot the angle distribution
%
%% Input
% ebsd - @EBSD
%
%% Flags
%
%% See also
% EBSD/calcAngleDistribution
%

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

%% make new plot
newMTEXplot;

%% get phases
phases = get(ebsd,'phase');
ph = unique(phases(phases>0));

% all combinations of phases
[ph1,ph2] = meshgrid(ph);
ph1 = ph1(tril(ones(size(ph1)))>0);
ph2 = ph2(tril(ones(size(ph2)))>0);

%% compute omega

CS = get(ebsd,'CSCell');
phMap = get(ebsd,'phaseMap');
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
  
  ebsd1 = subsref(ebsd,phases == ph1(i));
  ebsd2 = subsref(ebsd,phases == ph2(i));
  f(:,i) = calcAngleDistribution(ebsd1,ebsd2,'omega',omega,varargin{:});
  
  lg{i} = [get(ebsd1,'mineral') ' - ' get(ebsd2,'mineral')]; %#ok<AGROW>
end

%% plot

optiondraw(bar(omega/degree,max(0,f)),'BarWidth',1.5,varargin{:});

xlabel('misorientation angle in degree')
xlim([0,max(omega)/degree])
ylabel('percent')

legend(lg{:})
