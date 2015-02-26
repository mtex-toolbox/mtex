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

[mtexFig,isNew] = newMtexFigure(varargin{:});

% calc axis distribution
axes = calcAxisDistribution(obj,'SampleSize',10000,varargin{:});

% plot
plot(axes,'all','FundamentalRegion',varargin{:});

if isNew % finalize plot
  set(gcf,'Name','Misorientation Axes Distribution');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end
