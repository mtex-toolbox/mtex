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
%  superposition - plot superposed pole figures
%  points        - number of points to be plotted
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% EBSD/plotebsd S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

varargin = set_option_property(ebsd,varargin{:});

plotPDF(ebsd.orientations,h,'FigureTitle',inputname(1),varargin{:});
