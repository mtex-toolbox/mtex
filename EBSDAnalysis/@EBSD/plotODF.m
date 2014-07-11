function plotODF(ebsd,varargin)
% Plot EBSD data at ODF sections
%
% Input
%  ebsd - @EBSD
%
% Options
%  sections   - number of plots
%  points     - number of orientations to be plotted
%  all        - plot all orientations
%  phase      - phase to be plotted
%
% Flags
%  SIGMA  - (default)
%  ALPHA - 
%  GAMMA  -   
%  PHI1 - 
%  PHI2 - 
%  axisAngle - 
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

varargin = set_option_property(ebsd,varargin{:});

plotODF(ebsd.orientations,'FigureTitle',inputname(1),varargin{:});
