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
[f,omega] = CalcAngleDistribution(odf,varargin{:});


%% plot
%bar(omega/degree,max(0,f));
% xlim([0,max(omega)])
optionplot(omega/degree,max(0,f),varargin{:});
xlabel('orientation angle in degree')
