function plotAxisDistribution(obj,varargin)
% plot uncorrelated axis distribution
%
% Input
%  ebsd   - @EBSD
%  grains - @grainSet
%
% Options
%  resolution - resolution of the plots
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% calc axis distribution
axes = calcAxisDistribution(obj,'SampleSize',10000,varargin{:});

% plot
plot(axes,'all','FundamentalRegion',varargin{:});

set(gcf,'tag','AxisDistribution');
setappdata(gcf,'CS',axes.CS);
set(gcf,'Name','Axis Distribution');
