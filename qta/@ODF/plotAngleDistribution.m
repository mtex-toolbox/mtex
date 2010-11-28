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

%%
[f,omega] = angleDistribution(odf,varargin{:});


%% plot
plot(omega/degree,max(0,f),'.');
xlabel('orientation angle in degree')
