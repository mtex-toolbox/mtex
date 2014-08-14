function varargout = plotAxisDistribution(ori,varargin)
% plot uncorrelated axis distribution
%
% Input
%  ori - @orientation
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

mtexFig = newMtexFigure('ensureTag','AxisDistribution',varargin{:});

% plot
axes = ori.axis;
[varargout{1:nargout}] = plot(axes,'symmetrised','FundamentalRegion',varargin{:},'parent',mtexFig.gca);

set(gcf,'tag','AxisDistribution');
setappdata(gcf,'CS',axes.CS);
set(gcf,'Name','Axis Distribution');
