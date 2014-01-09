function plotpdf(grains,h,varargin)
% plot pole figures
%
% Syntax
%   plotpdf(ebsd,[h1,..,hN])
%
% Input
%  ebsd - @GrainSet
%  h    - @Miller crystallographic directions
%
% Options
%  SUPERPOSITION - plot superposed pole figures
%  POINTS        - number of points to be plotted
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot complete (hemi)--sphere
%
% See also
% S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[ax,grains,h,varargin] = getAxHandle(grains,h,varargin{:});

varargin = set_option_property(grains,varargin{:});

plotpdf(ax{:},grains.meanOrientation,h,...
  'FigureTitle',inputname(1),varargin{:});
