function plotAngleDistribution(odf,varargin)
% plot axis distribution
%
%% Input
%  odf - @ODF
%
%% Options
%  RESOLUTION - resolution of the plots
%  


varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

%% make new plot
newMTEXplot;

%% plotting grid

omega = linspace(0,pi);


%% plot
plot(omega,AngleDistribution(odf,omega,varargin{:}));
