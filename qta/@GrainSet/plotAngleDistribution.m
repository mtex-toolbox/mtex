function plotAngleDistribution( grains, varargin )


varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

%% make new plot
newMTEXplot;

%%
[f,omega] = calcAngleDistribution(grains,varargin{:});

%% plot

optiondraw(bar(omega/degree,max(0,f)),varargin{:});

xlabel('orientation angle in degree')
xlim([0,max(omega)/degree])
