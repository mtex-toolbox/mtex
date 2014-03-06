function plot(ebsd,varargin)
% bypasses ebsd plotting functions 
%
%% Input
%  ebsd - @EBSD
%
%% Flages
%  SCATTER       - three dimensional scatter plot
%  AXISANGLE     - axis angle projection
%  RODRIGUES     - rodrigues parameterization
%  POINTS        - number of orientations to be plotted
%  CENTER        - reference orientation
%
%% See also
% EBSD/scatter EBSD/plotspatial EBSD/plotpdf savefigure

% where to plot
[ax,ebsd,varargin] = getAxHandle(ebsd,varargin{:});

% determine plot type
if check_option(varargin,{'scatter','axisangle','rodrigues'}) && ...
  ~check_option(varargin,'colorcoding')
  scatter(ax{:},ebsd,varargin{:});
elseif check_option(varargin,{'sections','sigma','phi1','phi2','alpha','gamma'})
  plotodf(ax{:},ebsd,varargin{:});
elseif isfield(ebsd.options,'x') && isfield(ebsd.options,'y')
  plotspatial(ax{:},ebsd,varargin{:});
else
  h = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
  plotpdf(ax{:},ebsd,h,varargin{:});
end
