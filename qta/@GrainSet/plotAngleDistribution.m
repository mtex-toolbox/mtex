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

%%
[f,omega] = calcAngleDistribution(grains,varargin{:});

%% plot

optiondraw(bar(omega/degree,max(0,f)),varargin{:});

xlabel('orientation angle in degree')
xlim([0,max(omega)/degree])
