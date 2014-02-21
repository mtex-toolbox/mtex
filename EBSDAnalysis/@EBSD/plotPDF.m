function plotPDF(ebsd,h,varargin)
% plot pole figures
%
% Syntax
%   plotPDF(ebsd,[h1,..,hN],<options>)
%
% Input
%  ebsd - @EBSD
%  h    - @Miller crystallographic directions
%
% Options
%  SUPERPOSITION - plot superposed pole figures
%  POINTS        - number of points to be plotted
%
% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)--sphere
%
% See also
% EBSD/plotebsd S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[ax,ebsd,h,varargin] = getAxHandle(ebsd,h,varargin{:});

varargin = set_option_property(ebsd,varargin{:});

plotPDF(ax{:},ebsd.orientations,h,...
  'FigureTitle',inputname(1),varargin{:});
