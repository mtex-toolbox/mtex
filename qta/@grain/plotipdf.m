function plotipdf(grains,r,varargin)
% plot grain orientation into inverse pole figure

% get orientation
o = get(grains,'orientations');

% do something ????
varargin = set_option_property(grains,varargin{:});

% plot into inverse pole figure
plotipdf(o,r,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});
