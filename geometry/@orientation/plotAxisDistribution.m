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

[mtexFig,isNew] = newMtexFigure(varargin{:});

% plot
axes = ori.axis;
[varargout{1:nargout}] = plot(axes,'parent',mtexFig.gca,...
  'symmetrised','FundamentalRegion',varargin{:});

if isNew
  set(gcf,'Name','Axis Distribution');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end
