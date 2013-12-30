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

% where to plot
[ax,ebsd,varargin] = getAxHandle(ebsd,varargin{:});
if isempty(ax), newMTEXplot;end

%% calc axis distribution

axes = calcAxisDistribution(ebsd,'SampleSize',10000,varargin{:});

plot(ax{:},axes,'all','FundamentalRegion',varargin{:});

%% set tags

if isempty(ax)
  set(gcf,'tag','AxisDistribution');
  setappdata(gcf,'CS',get(axes,'CS'));
  name = inputname(1);
  if isempty(name), name = ebsd.comment;end
  set(gcf,'Name',['Axis Distribution of ',name]);
end

