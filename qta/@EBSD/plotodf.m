function plotodf(ebsd,varargin)
% Plot EBSD data at ODF sections
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  SECTIONS   - number of plots
%  points     - number of orientations to be plotted
%  all        - plot all orientations
%  phase      - phase to be plotted
%
%% Flags
%  SIGMA (default)
%  ALPHA
%  GAMMA      
%  PHI1
%  PHI2
%  AXISANGLE
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

[o ind] = get(ebsd,'orientations','CheckPhase',varargin{:});

varargin = set_option_property(ebsd(ind),varargin{:});

plotodf(o,...
  'FigureTitle',[inputname(1) ' (' get(ebsd,'comment') ')'],varargin{:});