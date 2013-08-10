function plot(ebsd,varargin)
% bypasses ebsd plotting functions 
%
% Input
%  ebsd - @EBSD
%
% Flages
%  scatter       - three dimensional scatter plot
%  axisAngle     - axis angle projection
%  Rodrigues     - rodrigues parameterization
%  points        - number of orientations to be plotted
%  center        - reference orientation
%
% See also
% EBSD/scatter EBSD/plotspatial EBSD/plotpdf savefigure

% where to plot
[ax,ebsd,varargin] = getAxHandle(ebsd,varargin{:});

% determine plot type
if check_option(varargin,{'scatter','axisangle','rodrigues'}) && ...
  ~check_option(varargin,'colorcoding')
  scatter(ax{:},ebsd,varargin{:});
elseif check_option(varargin,{'sections','sigma','phi1','phi2','alpha','gamma'})
  plotodf(ax{:},ebsd,varargin{:});
elseif isProp(ebsd,'x') && isProp(ebsd,'y')
  plotspatial(ax{:},ebsd,varargin{:});
else
  h = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
  plotpdf(ax{:},ebsd,h,varargin{:});
end
