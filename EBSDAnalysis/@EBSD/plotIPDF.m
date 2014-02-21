function plotIPDF(ebsd,varargin)
% plot inverse pole figures
%
% Input
%  ebsd - @EBSD
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%  
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

% make new plot
[ax,ebsd,varargin] = getAxHandle(ebsd,varargin{:});


varargin = set_option_property(ebsd,varargin{:});

if nargin > 1 && isa(varargin{1},'vector3d')
  r = varargin(1);
  varargin(1) = [];
else
  r = {};
end
plotIPDF(ax{:},ebsd.orientations,r{:},...
  'FigureTitle',inputname(1),varargin{:});
