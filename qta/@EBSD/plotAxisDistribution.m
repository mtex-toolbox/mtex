function plotAxisDistribution(ebsd,varargin)
% plot uncorrelated axis distribution
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  RESOLUTION - resolution of the plots
%  
%% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE  - plot entire (hemi)--sphere
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

%% make new plot
newMTEXplot;

%% 

plot(calcAxisDistribution(ebsd,'SampleSize',1000,varargin{:}),varargin{:},'all');

%% set tags

set(gcf,'tag','AxisDistribution');
name = inputname(1);
if isempty(name), name = ebsd.comment;end
set(gcf,'Name',['Axis Distribution of ',name]);

