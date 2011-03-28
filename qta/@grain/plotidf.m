function plotipdf(grains,r,varargin)
% plot grain orientation into inverse pole figure

% get orientation
[o ind] = get(grains,'orientations','CheckPhase',varargin{:});

% do something ????
varargin = set_option_property(grains(ind),varargin{:});

% plot into inverse pole figure
plotipdf(o,r,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

