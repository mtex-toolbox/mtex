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
%  COMPLETE - plot entire (hemi)--sphere
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% make new plot

[ax,ebsd,r,varargin] = getAxHandle(ebsd,r,varargin{:});

o = get(ebsd,'orientation');

varargin = set_option_property(ebsd,varargin{:});

plotipdf(ax{:},o,r,...
  'FigureTitle',[inputname(1) ' (' get(ebsd,'comment') ')'],varargin{:});
