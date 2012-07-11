function plot(ebsd,varargin)
% plots ebsd data 
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


% determine plot type
if check_option(varargin,{'scatter','axisangle','rodrigues'})
  scatter(ebsd,varargin{:});
elseif check_option(varargin,{'sections','sigma','phi1','phi2','alpha','gamma'})
  plotodf(ebsd,varargin{:});
elseif isfield(ebsd.options,'x') && isfield(ebsd.options,'y')
  plotspatial(ebsd,varargin{:});
else
  h = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
  plotpdf(ebsd,h,varargin{:});
end
