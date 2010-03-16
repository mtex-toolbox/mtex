function plotipdf(ebsd,r,varargin)
% plot inverse pole figures
%
%% Input
%  ebsd - @EBSD
%  r   - @vector3d specimen directions
%
%% Options
%  RESOLUTION - resolution of the plots
%  
%% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% make new plot


[o ind] = get(ebsd,'orientations','CheckPhase',varargin{:});

varargin = set_option_property(ebsd(ind),varargin{:});

plotipdf(o,r,...
  'FigureTitle',[inputname(1) ' (' get(ebsd,'comment') ')'],varargin{:});