function plotPDF(grains,h,varargin)
% plot mean orientation in pole figures
%
% Syntax
%   plotPDF(grains,[h1,..,hN])
%
% Input
%  grains - @GrainSet
%  h      - @Miller crystallographic directions
%
% Options
%  superposition - plot superposed pole figures
%  points        - number of points to be plotted
%
% Flags
%  antipodal - include <AxialDirectional.html antipodal symmetry>
%  complete  - plot complete (hemi)--sphere
%
% See also
% S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

varargin = set_option_property(grains,varargin{:});

plotPDF(grains.meanOrientation,h,...
  'FigureTitle',inputname(1),varargin{:});
