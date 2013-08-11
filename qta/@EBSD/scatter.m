function scatter(ebsd,varargin)
% plots ebsd data as scatter plot
%
% Syntax
%   scatter(ebsd)
%   scatter(ebsd,'property','mad')
%
% Input
%  ebsd - @EBSD
%
% Options
%  axisAngle - axis angle projection
%  Rodrigues - rodrigues parameterization
%  points    - number of orientations to be plotted
%  center    - orientation center
%
% See also
% EBSD/plotpdf savefigure

varargin = set_option_property(ebsd,varargin{:});

scatter(ebsd.orientations,'FigureTitle',inputname(1),varargin{:});
